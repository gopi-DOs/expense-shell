#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
   if [ $USERID -ne 0 ]
   then
        echo -e "$R please run the script with root privrlages $N"  | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo -e "$2 is...$R  failed $N"  | tee -a $LOG_FILE
      exit 1
    else 
      echo -e "$2...$G  success $N"  | tee -a $LOG_FILE
      fi 
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT 

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? " Installing mysql"

systemctl enable mysqld  &>>$LOG_FILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld   &>>$LOG_FILE
VALIDATE $? "start mysql"

mysql -h mysql.bng81s.online -u root -pExpenseApp@1 -e 'show databases;' &>>"$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "MySQL root password is not set up, configuring now." | tee -a "$LOG_FILE"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>"$LOG_FILE"
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already set up. ${Y}Skipping.${N}" | tee -a "$LOG_FILE"
fi

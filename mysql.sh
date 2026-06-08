#!/bin/bash

USRID=$(id -u)

CHECKROOT()
{
    if [ $USRID -ne 0 ]
    then
    echo -e " $R Not a Root User"
    exit 1
    fi
}

LOG_FOLDER="/var/log/shellscript-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 IS $R Fail $N"
        exit 1
    else
        echo -e "$2 Is $G Success $N"
    fi
}

echo "Time of Execution is : $TIMESTAMP "  &>>$LOG_FILE_NAME

CHECKROOT

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld  &>>$LOG_FILE_NAME
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting Root Passwod"



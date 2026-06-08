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

LOG_FOLDER="/var/log/expense-logs"
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
        echo -e "$2 iS $R Fail $N"
        exit 1
    else
        echo -e "$2 is $G Success $N"
    fi
}

echo "Time of Execution is : $TIMESTAMP "  &>>$LOG_FILE_NAME

mkdir -p $LOG_FOLDER

CHECKROOT



dnf install nginx -y  &>>$LOG_FILE_NAME
VALIDATE $? "Intall Nginx"

systemctl enable nginx  &>>$LOG_FILE_NAME
VALIDATE $? "Enable"

systemctl start nginx  &>>$LOG_FILE_NAME
VALIDATE $? "Start"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE_NAME
VALIDATE $? "Remove"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip  &>>$LOG_FILE_NAME
VALIDATE $? "Download"

cd /usr/share/nginx/html  &>>$LOG_FILE_NAME
VALIDATE $? "Change Directory"

unzip /tmp/frontend.zip  &>>$LOG_FILE_NAME
VALIDATE $? "Unzip File"

systemctl restart nginx  &>>$LOG_FILE_NAME 
VALIDATE $? "Restart"
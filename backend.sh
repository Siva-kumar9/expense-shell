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

CHECKROOT


dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disable Existing Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enable Nodejs:20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Install NodeJS"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Create Expense User"
else
    echo -e "Expense user is already Exist ... $Y Skipping $N"
fi


mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "Create Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOG_FILE_NAME
VALIDATE $? "Download ZIP File"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "UnZIP File"

cd /app

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing Dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service  &>>$LOG_FILE_NAME


#Prepare SQL

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing SQL"

mysql -h 172.31.34.8 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "Setting Up Transaction schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Reload"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Start"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enable"




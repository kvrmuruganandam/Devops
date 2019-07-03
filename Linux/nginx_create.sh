#!/bin/bash

#Nginx Installation
yum install nginx -y
echo "Welcom To Nginx Web server" > /usr/share/nginx/html/index.html
service nginx enable
service nginx restart
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
fi


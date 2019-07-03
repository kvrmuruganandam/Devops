#!/bin/bash
yum install java -y
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
service tomcat enable
service tomcat restart
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload
fi
echo "Tomcat 7 Installed Successfully"


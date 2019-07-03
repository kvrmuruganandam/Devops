#!/bin/bash
yum remove tomcat tomcat-webapps tomcat-admin-webapps -y
rm -rf /etc/tomcat
rm -rf /usr/share/tomcat
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --remove-port=8080/tcp
firewall-cmd --reload
fi
echo "tomcat-7 successfully removed"

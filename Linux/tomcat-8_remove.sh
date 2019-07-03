#!/bin/bash
rm -rf /usr/local/tomcat
sed -i "/CATALINA_HOME/d" ~/.bashrc
rem=`ps aux|grep tomcat|awk '{print $2}'`
for i in $rem
do
kill -9 $i 2>/dev/null
done
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --remove-port=8080/tcp
firewall-cmd --reload
fi


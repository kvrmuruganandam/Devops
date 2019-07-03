#!/bin/bash
yum install java -y
mkdir /usr/local/tomcat
cd /usr/local/tomcat
yum install wget -y
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
tar xzf apache-tomcat-9.0.21.tar.gz
mv apache-tomcat-9.0.21/* .
rm -rf apache-tomcat*
echo "export CATALINA_HOME="/usr/local/tomcat"" >> ~/.bashrc
source ~/.bashrc
./bin/startup.sh
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload
fi
echo " Tomcat 9 Installed Successfully"


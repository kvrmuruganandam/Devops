#!/bin/bash

#Apache Installation
yum install httpd -y
chmod -R 755 /var/www
echo "Welcome to Apache Web Server" > /var/www/html/index.html
service httpd enable
service httpd restart
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --reload
fi
echo "Apache Webserver Installed Successfully"

#MariaDB installation
yum install mariadb -y
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('vtg@123')";
server mariadb enable
server mariadb start

#php installation
yum install php php-mysql php-pdo php-gd php-mbstring -y
echo -e "<?php \nphpinfo();\n?>" > /var/www/html/info.php

#phpmyadmin installation
yum install epel-release -y
yum install phpMyAdmin -y
sed -i -e '0,/Require ip ::1/s///' -e '0,/Require ip 127.0.0.1/s//Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
systemctl reload httpd


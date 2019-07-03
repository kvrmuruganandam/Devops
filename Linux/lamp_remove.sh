#!/bin/bash

#remove httpd with configuration file
yum remove httpd -y
rm -rf /etc/httpd*

#remove database
yum remove mariadb -y

#remove php and phpMyAdmin with configuration file
yum remove php php-mysql php-pdo php-gd php-mbstring -y
rm -rf /etc/php*
yum remove phpMyAdmin -y


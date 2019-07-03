#!/bin/bash

read -sp "Enter Password for Mysql Secure Installation: " new
yum install wget -y
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum install mysql-server -y
mysql_secure_installation <<eoh

y
$new
$new
y
y
y
y
eoh
service mysqld enable
service mysqld restart
echo "Mysql server-5.6 installed successfully"


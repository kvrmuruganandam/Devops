#!/bin/bash
read -sp "Enter Password for Mysql Secure Installation: " new
yum install mariadb-server -y
mysql_secure_installation <<eoh

y
$new
$new
y
y
y
y
eoh
service mariadb enable
service mariadb restart
echo "MariaDB Server-5.5 installed successfully"


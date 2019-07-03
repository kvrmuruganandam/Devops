#!/bin/bash
read -sp "Enter Password for Mysql Secure Installation: " NEW
yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm -y
yum install mysql-community-server -y
temp_password=$(grep 'A temporary password' /var/log/mysqld.log |tail -1|rev | cut -d' ' -f1 | rev)

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '8)13ftQG5OYl'; flush privileges;" > reset_pass.sql

mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql

yum -y install expect
MYSQL_ROOT_PASSWORD="8)13ftQG5OYl"
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL_ROOT_PASSWORD\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password?\"
send \"$NEW\r\"
expect \"Re-enter new password?\"
send \"$NEW\r\"
expect \"Do you wish to continue with the password provided?\"
send \"y\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"
service mysqld enable
service mysqld restart
echo "Mysql server-5.7 installed successfully"


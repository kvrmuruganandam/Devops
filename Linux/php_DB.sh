#!/bin/bash
#PHP installation

php_install(){
echo "           PHP Installation"
echo "		 ****************"
echo "1.PHP-7.3"
echo "2.PHP-7.2"
echo "3.PHP-7.1"
echo "4.PHP-7.0"
read -p "choose: " a
if [ $a == '1' ]
then
yum install epel-release yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php73
yum install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd -y
echo "PHP-7.3 Successfully installed"
elif [ $a == '2' ]
then
yum install epel-release yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php72
yum install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd -y
echo "PHP-7.2 Successfully installed"
elif [ $a == '3' ]
then
yum install epel-release yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php71
yum install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql -y
echo "PHP-7.1 Successfully installed"
elif [ $a == '4' ]
then
yum install epel-release yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php70
yum install php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql -y
echo "PHP-7.0 Successfully installed"
else
echo " None of the option"
fi
}


#PHP removal

php_remove(){
version=`php -v|head -1|cut -d' ' -f2|cut -d'.' -f1,2`
read -p "Do you want to remove PHP Version $version (y/n):" ans
if [ $ans == 'y' ]
then 
if [ $version == '7.0' ]
then
yum-config-manager --disable remi-php70
yum remove php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql -y
elif [ $version == '7.1' ]
then
yum-config-manager --disable remi-php71
yum remove php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql -y
elif [ $version == '7.2' ]
then
yum-config-manager --disable remi-php72
yum remove php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql -y
elif [ $version == '7.3' ]
then
yum-config-manager --disable remi-php73
yum remove php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql -y
else
echo " "
fi
fi
}



#Mysql or MariaDB installation

mysql_install(){
echo "           Database Installation"
echo "           ****************"
echo "1.Mysql-5.6"
echo "2.Mysql-5.7"
echo "3.MariaDB-5.5"
echo "4.MariaDB-10.1"
read -p "choose: " m
case $m in
1)
	read -sp "Enter Password for Mysql Secure Installation: " new
	yum install wget -y
        wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
        rpm -ivh mysql-community-release-el7-5.noarch.rpm
        yum install mysql-server -y
        mysql_secure
	service mysqld enable
        service mysqld restart
        echo "Mysql server-5.6 installed successfully"
        ;;
2)
	read -sp "Enter Password for Mysql Secure Installation: " NEW
	yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm -y
        yum install mysql-community-server -y
        mysql_secure_latest
	service mysqld enable
        service mysqld restart
        echo "Mysql server-5.7 installed successfully"
        ;;
3)
	read -sp "Enter Password for Mysql Secure Installation: " new
	yum install mariadb-server -y
        mysql_secure
	service mariadb enable
        service mariadb restart
        echo "MariaDB Server-5.5 installed successfully"
        ;;

4)
	read -sp "Enter Password for Mysql Secure Installation: " new
	cat<<EOF>/etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
yum install mariadb-server -y
mysql_secure
service mariadb enable
service mariadb restart
echo "MariaDB Server-10.1 installed successfully"
;;
*)
	echo "Sorry choose Anyone"
;;
esac
}

#Mysql or MariaDB secure installation

mysql_secure(){
sudo mysql_secure_installation <<eoh

y
$new
$new
y
y
y
y
eoh
}

mysql_secure_latest(){
read -sp "Enter Password for Mysql Secure Installation: " NEW
temp_password=$(grep 'A temporary password' /var/log/mysqld.log |tail -1|rev | cut -d' ' -f1 | rev)

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '8)13ftQG5OYl'; flush privileges;" > reset_pass.sql

mysql -u root --password="$temp_password" --connect-expired-password < reset_pass.sql

yum -y install expect
#// Not required in actual script
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
}

# Mysql or MariaDB removal

mysql_remove(){
check=`yum list installed|egrep "mysql|Maria"`
if [ $? == '0' ]
then
echo " "
echo "You have installed "
echo "**********************************************************************************"
mysql -V
echo "**********************************************************************************"
echo " "
read -p "Do you want to remove(y/n): " opt
if [ $opt = 'y' ]
then
mysql -V|grep Maria > /dev/null
if [ $? == '0' ]
then
yum remove mariadb  mariadb-server -y
remove=`rpm -qa|grep Maria|awk 'NR%3{printf "%s ",$0;next;}1'`
for i in $remove
do
rpm -e --nodeps $i
done
rm -rf /etc/yum.repos.d/MariaDB.repo
rm -rf /var/lib/mysql
rm -rf /var/log/mysql*
rm -rf /var/log/mariadb*
else
yum remove mysql mysql-server -y
remove=`rpm -qa|grep mysql|awk 'NR%3{printf "%s ",$0;next;}1'`
for i in $remove
do
rpm -e --nodeps $i
done
rm -rf /var/lib/mysql
rm -rf /var/log/mysqld*
fi
else
echo "Operation Aborted"
fi
else
echo "You have not installed Mysql or MariaDB"
fi
}


#Main Page
echo "Welcome To PHP and DATABASE Management"
echo "**************************************"
echo "1.Database"
echo "2.PHP"
read -p "Choose: " pick
if [ $pick == '1' ]
then
echo "		Welcome To Database Management"
echo " 		******************************"
echo "1.Install DB"
echo "2.Remove DB"
read -p "Choose: " opt
if [ $opt == '1' ]
then
mysql_install
elif [ $opt == '2' ]
then
mysql_remove
else
echo "Sorry Choose Anyone"
fi

elif [ $pick == '2' ]
then
echo "          Welcome To PHP Management"
echo "          ******************************"
echo "1.Install PHP"
echo "2.Remove PHP"
read -p "Choose: " opt
if [ $opt == '1' ]
then
php_install
elif [ $opt == '2' ]
then
php_remove
else
echo "Sorry Choose Anyone"
fi
else
	echo "Sorry Choose Anyone"
fi

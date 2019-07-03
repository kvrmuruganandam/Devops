#!/bin/bash
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


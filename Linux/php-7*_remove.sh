#!/bin/bash
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


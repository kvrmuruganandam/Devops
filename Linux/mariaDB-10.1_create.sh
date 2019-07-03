#!/bin/bash
read -sp "Enter Password for Mysql Secure Installation: " new
cat<<EOF>/etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
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
echo "MariaDB Server-10.1 installed successfully"



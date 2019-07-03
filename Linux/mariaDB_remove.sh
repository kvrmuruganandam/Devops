#!/bin/bash
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


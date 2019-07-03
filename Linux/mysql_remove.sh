#!/bin/bash
yum remove mysql mysql-server -y
remove=`rpm -qa|grep mysql|awk 'NR%3{printf "%s ",$0;next;}1'`
for i in $remove
do
rpm -e --nodeps $i
done
rm -rf /var/lib/mysql
rm -rf /var/log/mysqld*


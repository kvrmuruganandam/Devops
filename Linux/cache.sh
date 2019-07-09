cache_install()
{
echo "Welcome To Cache Management"
echo "***************************"

yum install memcached libmemcached -y
Ip=`hostname -I`
sed -i '/OPTIONS/c\OPTIONS=" -l $Ip -U 0"  /etc/sysconfig/memcached
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=11211/tcp
firewall-cmd --reload
fi
systemctl restart memcached
systemctl enable memcached
echo "Memcached Server Installed Successfully"

yum install epel-release yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi
yum install redis -y
Ip=`hostname -I`
sed -i ':a;N;$!ba; s/bind 127.0.0.1/bind 127.0.0.1 $Ip/2' /etc/redis.conf
systemctl restart redis
systemctl enable redis
echo "Redis Server Installed Successfully"

}

cache_remove(){
echo "Welcome To Cache Management"
echo "***************************"
echo 
verify=`yum list installed|grep memcached`
if [ $? == '0' ]
then
	read -p "Do you want to remove Memcached(y/n): " pick
if [ $pick == 'y' ]
then	
yum remove memcached libmemcached -y
rm -rf /etc/sysconfig/memcache*
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --remove-port=11211/tcp
firewall-cmd --reload
fi
echo "Memcached cache Server Removed Successfully"
else
	echo "Operation Aborted"
fi
else
	echo "You have not installed Memcached"
fi
elif [ $input == '2' ]
then
verify=`yum list installed|grep redis`
if [ $? == '0' ]
then
        read -p "Do you want to remove Redis(y/n): " pick
if [ $pick == 'y' ]
then
yum-config-manager --disable remi
yum remove redis -y
rm -rf /etc/redis*
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --remove-port=6379/tcp
firewall-cmd --reload
fi
echo "Redis cache Server Removed Successfully"
else
        echo "Operation Aborted"
fi
else
        echo "You have not installed Redis"
fi
else
	echo "Sorry Choose Anyone"
fi

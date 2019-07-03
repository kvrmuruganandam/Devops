#!/bin/bash
#Apache virtualhost configuration
read -p "Enter Your VirtualHost Name(should be like www.example.com and start with www): " FQDN
Domain=`echo $FQDN|cut -d'.' -f2,3`
Ip=`hostname -I`
echo "$Ip $Domain $FQDN" >> /etc/hosts
mkdir -p /var/www/$FQDN/public_html
touch /var/www/$FQDN/error.log
touch /var/www/$FQDN/requests.log combined
chmod -R 755 /var/www
setenforce 0
echo "Welcome To $FQDN" > /var/www/$FQDN/public_html/index.html
cat<<EOF>/etc/httpd/conf.d/${FQDN}.conf
<VirtualHost *:80>
    ServerName $FQDN
    ServerAlias $Domain
    DocumentRoot /var/www/$FQDN/public_html
    ErrorLog /var/www/$FQDN/error.log
    CustomLog /var/www/$FQDN/requests.log combined
</VirtualHost>
EOF
service httpd reload
echo " "
echo "VirtualHosting $FQDN Configured Successfully" 


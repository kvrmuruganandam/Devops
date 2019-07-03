#!/bin/bash

#Nginx virtualhost configuration
read -p "Enter Your VirtualHost Name(should be like www.example.com and start with www): " FQDN
Domain=`echo $FQDN|cut -d'.' -f2,3`
Ip=`hostname -I`
echo "$Ip $Domain $FQDN" >> /etc/hosts
mkdir -p /var/www/$FQDN/public_html
chmod -R 755 /var/www
setenforce 0
echo "Welcome to $FQDN" > /var/www/$FQDN/public_html/index.html
cat<<EOF>/etc/nginx/conf.d/${FQDN}.conf
server {
    listen       80;
    server_name  $Domain $FQDN;

    location / {
        root   /var/www/$FQDN/public_html/;
         index  index.html index.htm;
    }
}
EOF
service nginx reload
echo "Nginx VirtualHost $FQDN configured successfully"

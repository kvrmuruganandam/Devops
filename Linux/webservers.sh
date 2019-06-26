#!/bin/bash

#virtualhost configuration

vhost_configure(){
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
}


#Apache default configuration

httpd(){
check=`yum list installed|grep httpd `
if [ $? == '0' ]
then
echo " "
echo "Apache Web server already Installed"
echo " "
else
yum install httpd mod_ssl openssl -y
chmod -R 755 /var/www
echo "Welcome to Apache Web Server" > /var/www/html/index.html
service httpd enable
service httpd restart
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --reload
fi
echo "Apache Webserver Installed Successfully"
fi
}

#Apache Removal
remove_httpd(){
check=`yum list installed|grep httpd `
if [ $? == '0' ]
then
echo " "
read -p "Do you want to remove Apache Web server(y/n): " pick
echo " "
if [ $pick == 'y' ]
then
yum remove httpd* -y
rm -rf /var/www
rm -rf /etc/httpd
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --remove-port=80/tcp
firewall-cmd --zone=public --permanent --remove-port=443/tcp
firewall-cmd --reload
fi
yum remove mod_ssl -y
yum remove openssl -y  
echo "Apache Web Server Removed Successfully"
else
echo "Operation Aborted"
fi
else
echo "You have not installed Apache Web server"
fi
}


#Apache virtualhost configuration

httpd_virtualhost(){
read -p "Do You need SSL for VirtualHost (y/n): " ssl
if [ $ssl == "y" ]
then
vhost_configure
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/${FQDN}.key -out /etc/pki/tls/certs/${FQDN}.crt
cat<<EOF>/etc/httpd/conf.d/${FQDN}.conf
<VirtualHost *:443>
     ServerAdmin info@$Domain
     ServerName $FQDN
     ServerAlias $Domain
     DocumentRoot /var/www/$FQDN/public_html/
     ErrorLog /var/www/$FQDN/error.log
     CustomLog /var/www/$FQDN/access.log combined

     SSLEngine On
     SSLCertificateFile /etc/pki/tls/certs/${FQDN}.crt
     SSLCertificateKeyFile /etc/pki/tls/private/${FQDN}.key

</VirtualHost>
EOF
service httpd reload
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload
fi
echo " "
echo "SSL certificate Configured Successfully for $FQDN VirtualHost"
else
vhost_configure
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
fi
}

#remove apache virtualhost
remove_hvirtualhost(){
echo " "
echo "You have following VirtualHosts:"
echo " "
find /var/www/ -type d -name "www.*"|cut -d'/' -f4
echo " "
read -p "Enter Your VirtualHost Name: " FQDN
echo " "
read -p "Do you want to remove Apache VirtualHost(y/n): " pick
echo " "
if [ $pick == 'y' ]
then
rm -rf /etc/httpd/conf.d/${FQDN}.conf
rm -rf /var/www/$FQDN
sed -i "/$FQDN/d" /etc/hosts
service httpd reload
echo "VirtualHost $FQDN removed Successfully"
else
echo "Operation Aborted"
fi
}

ssl_creation(){
echo " "
echo "You have following VirtualHosts:"
echo " "
find /var/www/ -type d -name "www.*"|cut -d'/' -f4
echo " "
read -p "Enter Your VirtualHost Name: " FQDN
yum install mod_ssl -y 2&>1 /dev/null
yum install openssl -y 2&>1 /dev/null
Domain=`echo $FQDN|cut -d'.' -f2,3`
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/${FQDN}.key -out /etc/pki/tls/certs/${FQDN}.crt
cat<<EOF>/etc/httpd/conf.d/${FQDN}.conf
<VirtualHost *:443>
     ServerAdmin info@$Domain
     ServerName $FQDN
     ServerAlias $Domain
     DocumentRoot /var/www/$FQDN/public_html/
     ErrorLog /var/www/$FQDN/error.log
     CustomLog /var/www/$FQDN/access.log combined

     SSLEngine On
     SSLCertificateFile /etc/pki/tls/certs/${FQDN}.crt
     SSLCertificateKeyFile /etc/pki/tls/private/${FQDN}.key

</VirtualHost>
EOF
service httpd reload
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
fi
echo "SSL certificate Configured Successfully for $FQDN VirtualHost"
}

remove_ssl(){
echo " "
echo "You have following VirtualHosts:"
echo " "
find /etc/pki/tls/* -name "www.*"|cut -d'/' -f6|tail -1|cut -d'.' -f1-3
echo " "
read -p "Enter Your VirtualHost Name: " FQDN
Domain=`echo $FQDN|cut -d'.' -f2,3`
rm -rf /etc/pki/tls/certs/${FQDN}.crt
rm -rf /etc/pki/tls/private/${FQDN}.key
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
echo "SSL Certificate Successfully Removed for $FQDN VirtualHost"
}

#Nginx default configuration

nginx(){
read -p "Do you need SSL for default site (y/n): " ssl
if [ $ssl == "y" ]
then
yum install nginx mod_ssl openssl -y 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/server.key -out /etc/pki/tls/certs/server.crt
echo "Welcom To NGINX Web server" > /usr/share/nginx/html/index.html
cat<<EOF>/etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

server {
        listen       443 ssl http2 default_server;
        listen       [::]:443 ssl http2 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

	ssl_certificate /etc/pki/tls/certs/server.crt;
        ssl_certificate_key /etc/pki/tls/private/server.key;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
       }
    }
}
EOF
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
fi
service nginx restart
else
yum install nginx mod_ssl openssl -y
echo "Welcom To Nginx Web server" > /usr/share/nginx/html/index.html
service nginx restart
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload
fi
fi
}

#Nginx virtualhost configuration

nginx_virtualhost(){
read -p "Do you need SSL for VirtualHost (y/n): " ssl
if [ $ssl == "y" ] 
then
vhost_configure
echo "Welcome to $FQDN" > /var/www/$FQDN/public_html/index.html
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/${FQDN}.key -out /etc/pki/tls/certs/${FQDN}.crt
cat<<EOF>/etc/nginx/conf.d/${FQDN}.conf
server {
        listen       443 ssl http2 ;
        listen       [::]:443 ssl http2 ;
        server_name  $Domain $FQDN;
        root         /var/www/$FQDN/public_html;

        ssl_certificate /etc/pki/tls/certs/${FQDN}.crt;
        ssl_certificate_key /etc/pki/tls/private/${FQDN}.key;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
       }
    }

EOF
service nginx reload
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
fi 
echo "Nginx VirtualHost $FQDN configured with SSL successfully"
else
vhost_configure
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
fi
}

#Nginx Removal
remove_nginx(){
echo " "
read -p "Do you want to remove Nginx Web server(y/n): " pick
echo " "
if [ $pick == 'y' ]
then
yum remove nginx -y
rm -rf /usr/share/nginx 2>/dev/null
rm -rf /etc/nginx 2>/dev/null
rm -rf /etc/pki/tls/certs/* 2>/dev/null
rm -rf /etc/pki/tls/private/* 2>/dev/null
rm -rf /var/www/* 2>/dev/null
remove=`rpm -qa|grep nginx|awk 'NR%3{printf "%s ",$0;next;}1'`
for i in $remove
do
rpm -e --nodeps $i
done
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --remove-port=80/tcp
firewall-cmd --permanent --remove-port=443/tcp
firewall-cmd --reload
fi
yum remove mod_ssl -y 2&>1 /dev/null
yum remove openssl -y  2&>1 /dev/null
echo "Nginx Web Server Removed Successfully"
else
echo "Operation Aborted"
fi
}


#remove nginx virtualhost
remove_nvirtualhost(){
echo " "
echo "You have following VirtualHosts:"
echo " "
find /var/www/ -type d -name "www.*"|cut -d'/' -f4
echo " "
read -p "Enter Your VirtualHost Name: " FQDN
echo " "
read -p "Do you want to remove Nginx VirtualHost(y/n): " pick
echo " "
if [ $pick == 'y' ]
then
rm -rf /etc/nginx/conf.d/${FQDN}.conf
rm -rf /var/www/$FQDN
sed -i "/$FQDN/d" /etc/hosts
service nginx restart
echo "VirtualHost $FQDN removed Successfully"
else
echo "Operation Aborted"
fi
}

#SSL configuration for Nginx VirtualHost
ssl_nginx_vhost(){
echo " "
echo "You have following VirtualHosts:"
echo " "
find /var/www/ -type d -name "www.*"|cut -d'/' -f4
echo " "
read -p "Enter Your VirtualHost Name: " FQDN
Domain=`echo $FQDN|cut -d'.' -f2,3`
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/${FQDN}.key -out /etc/pki/tls/certs/${FQDN}.crt
cat<<EOF>/etc/nginx/conf.d/${FQDN}.conf
server {
        listen       443 ssl http2 ;
        listen       [::]:443 ssl http2 ;
        server_name $Domain $FQDN;
        root         /var/www/$FQDN/public_html;

        ssl_certificate /etc/pki/tls/certs/${FQDN}.crt;
        ssl_certificate_key /etc/pki/tls/private/${FQDN}.key;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
       }
    }

EOF
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload
fi
service nginx reload
echo "SSL certification configured successfully for VirtualHost $FQDN"
}

#SSL removal
remove_nginx_ssl(){
echo " "
echo "You have SSL for following VirtualHosts:"
echo " "
find /etc/pki/tls/* -name "www.*"|cut -d'/' -f6|tail -1|cut -d'.' -f1-3
echo " "
read -p "Enter Your VirtualHost Name: " FQDN
Domain=`echo $FQDN|cut -d'.' -f2,3`
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
rm -rf /etc/pki/tls/private/${FQDN}.key
rm -rf /etc/pki/tls/private/${FQDN}.crt
service nginx reload
echo "SSL for $FQDN is successfully removed"
}


#Tomcat installation
tomcat(){
echo "		Welcome To Tomcat Management"
echo "		****************************"
echo "1.Tomcat-7"
echo "2.Tomcat-8.5"
echo "3.Tomcat-9"
read -p "Choose: " tom
check=`yum list installed|grep grep `
if [ $? == '0' ]
then
echo " "
echo "Tomcat already Installed"
echo " "
else
if [ $tom == 1 ]
then
yum install java -y
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
service tomcat enable
service tomcat restart
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload
fi
echo "Tomcat 7 Installed Successfully"
elif [ $tom == 2 ]
then
yum install java -y
mkdir /usr/local/tomcat
cd /usr/local/tomcat
yum install wget -y
wget http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.42/bin/apache-tomcat-8.5.42.tar.gz
tar xzf apache-tomcat-8.5.42.tar.gz
mv apache-tomcat-8.5.42/* .
rm -rf apache-tomcat*
echo "export CATALINA_HOME="/usr/local/tomcat"" >> ~/.bashrc
source ~/.bashrc
./bin/startup.sh
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload
fi
echo "Tomcat 8.5 Installed Successfully"
elif [ $tom == 3 ]
then
yum install java -y
mkdir /usr/local/tomcat
cd /usr/local/tomcat
yum install wget -y
wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
tar xzf apache-tomcat-9.0.21.tar.gz
mv apache-tomcat-9.0.21/* .
rm -rf apache-tomcat*
echo "export CATALINA_HOME="/usr/local/tomcat"" >> ~/.bashrc
source ~/.bashrc
./bin/startup.sh
check=`yum list installed|grep firewall `
if [ $? == '0' ]
then
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload
fi
echo " Tomcat 9 Installed Successfully"
else
echo "Sorry Choose Anyone"
fi
fi
}

#Tomcat removal
remove_tomcat(){
check=`yum list installed|grep tomcat`
if [ $? == '0' ]
then
cd /usr/local/tomcat 2>/dev/null
if [ $? == '0' ]
then
version=`./bin/version.sh 2>/dev/null|grep -i "Server number"|awk '{print $3}'|cut -d'.' -f1`
read -p "You have installed Tomcat Version $version. Do You want to remove(y/n): " choose
if [ $choose == 'y' ]
then
if [ $version == '9' ]
then
rm -rf /usr/local/tomcat
sed -i "/CATALINA_HOME/d" ~/.bashrc
rem=`ps aux|grep tomcat|awk '{print $2}'`
for i in $rem
do
kill -9 $i 2>/dev/null
done
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --remove-port=8080/tcp
firewall-cmd --reload
fi
else 
rm -rf /usr/local/tomcat
sed -i "/CATALINA_HOME/d" ~/.bashrc
rem=`ps aux|grep tomcat|awk '{print $2}'`
for i in $rem
do
kill -9 $i 2>/dev/null
done
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --remove-port=8080/tcp
firewall-cmd --reload
fi
fi
else 
echo "Operation Aborted"
fi
else
rem_def_tom
fi
else
	echo "you have not installed Tomcat"
fi
}

rem_def_tom(){
ls /usr/share/tomcat 2&>1 /dev/null
if [ $? == '0' ]
then
read -p "You have installed Tomcat Version 7. Do You want to remove(y/n): " choose
if [ $choose == 'y' ]
then
yum remove tomcat tomcat-webapps tomcat-admin-webapps -y
rm -rf /etc/tomcat
rm -rf /usr/share/tomcat
check=`yum list installed|grep firewall`
if [ $? == '0' ]
then
firewall-cmd --permanent --remove-port=8080/tcp
firewall-cmd --reload
fi
else 
echo "Operation Aborted"
fi
else
echo "You have not installed tomcat"
fi
}





#LAMP installation
lamp(){
#Apache installation
httpd

#mariadb installation
yum install mariadb -y
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('vtg@123')";
server mariadb enable
server mariadb start

#php installation
yum install php php-mysql php-pdo php-gd php-mbstring -y
echo -e "<?php \nphpinfo();\n?>" > /var/www/html/info.php

#phpmyadmin installation
yum install epel-release -y
yum install phpMyAdmin -y
sed -i -e '0,/Require ip ::1/s///' -e '0,/Require ip 127.0.0.1/s//Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
systemctl reload httpd
}

remove_lamp(){
remove_httpd
yum remove mariadb -y
yum remove php php-mysql php-pdo php-gd php-mbstring -y
yum remove phpMyAdmin -y
}

server_main_page(){
                echo "1.Install Web Server"
                echo "2.Configure VirtualHost"
                echo "3.Configure SSL Certificate for vHost"
                echo "4.Remove VirtualHost"
                echo "5.Remove Web server"
                echo "6.Remove SSL Certificate for vHost"
}
#Main page

echo "		Welcom To Webserver Management"
echo "		******************************"
echo "1.Apache"
echo "2.Nginx"
echo "3.Tomcat"
echo "4.LAMP"
read -p "Choose: " var
echo " "
case $var in
	1) 
		echo "		Welcome To Apache Web server Management"
		echo "		***************************************"
		server_main_page
		read -p "Choose: " a
		case $a in
		1)
			httpd
			;;
		2)      
			check=`yum list installed|grep httpd`
			if [ $? == '0' ]
			then
			httpd_virtualhost
			else
			echo "Please Install Httpd"
			fi
			;;
		3) 
			ssl_creation
			;;
		4)	remove_hvirtualhost
			;;
		5)	remove_httpd
			;;
		6)	remove_ssl
			;;
		esac
		;;
	2) 
		echo "          Welcome To Nginx Web server Management"
                echo "          ***************************************"
                server_main_page
		read -p "Choose: " a
                case $a in
                1)
                        nginx
                        ;;
                2)
			check=`yum list installed|grep nginx`
                        if [ $? == '0' ]
                        then
                        nginx_virtualhost
                        else
                        echo "Please Install Nginx"
                        fi
                        ;;
                3) 
                        ssl_nginx_vhost
                        ;;
                4)      remove_nvirtualhost
                        ;;
                5)      remove_nginx
                        ;;
                6)      remove_nginx_ssl
                        ;;
		esac
		;;
	3)
		echo "		Welcome To Tomcat Application Server management"
		echo " 		***********************************************"
		echo "1.Install Tomcat"
		echo "2.Remove Tomcat"
		read -p "choose: " a
		case $a in
		1)
			tomcat
			;;
		2)
			remove_tomcat
			;;
		esac
		;;
	4)
		echo "          Welcome To LAMP Server management"
                echo "          ***********************************************"
                echo "1.Install LAMP"
                echo "2.Remove LAMP"
                read -p "choose: " a
                case $a in
                1)
                        lamp
                        ;;
                2)
                        remove_lamp
                        ;;
		esac
		;;
	*)
		echo "Sorry, Choose Anyone"
		;;
esac

#!/usr/bin/ruby
#
#
#
execute "yum install httpd -y" do							#apache installation
end

execute "systemctl start httpd" do							#start apache service
end

execute "firewall-cmd --add-port=80/tcp --permanent" do   				#firewall rule for port 80
end

execute "firewall-cmd --add-port=443/tcp --permanent" do                                #firewall rule for port 443
end

execute "firewall-cmd --reload" do							#reload firewall
end

execute "yum install mariadb mariadb-server -y" do					#mariaDB installation
end

execute "mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('vtg@123');" do	#user account creation
end

execute "systemctl start mariadb" do 							#start mariDB service
end

execute "yum install php php-mysql -y" do						#php installation
end

execute "echo > /var/www/html/info.php" do						#info file creation
end

open('/var/www/html/info.php', 'w') do |f|						#put content to info.php
 f.puts "<?php phpinfo();?>"
end

execute "yum install epel-release -y" do						#epel repo installation
end

execute "yum install phpMyAdmin -y" do							#phpmyadmin installation
end

execute "systemctl reload httpd" do							#reload apache service
end


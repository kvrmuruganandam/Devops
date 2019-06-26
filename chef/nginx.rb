#
# Cookbook Name:: Nginx
# Recipe:: default
#
#
#Nginx Installation 

package 'nginx' do
action :install
end

file '/usr/share/html/index.html' do
content 'Welcome To Nginx Web server' 
end

service 'nginx' do
action :restart
end

execute 'httpd_firewall' do
  command '/usr/bin/firewall-cmd  --permanent --zone public --add-service http'
  ignore_failure true
end

execute 'reload_firewall' do
  command '/usr/bin/firewall-cmd --reload'
  ignore_failure true
end



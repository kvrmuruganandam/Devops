#
# Cookbook Name:: Apache
# Recipe:: default
#
#
#Apache Installation 

package 'httpd' do
action :install
end

file '/var/www/html/index.html' do
content 'Welcome To Apache Web server' 
end

service 'httpd' do
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


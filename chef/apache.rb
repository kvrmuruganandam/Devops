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

execute 'firewall-rule' do
command '
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload '
only_if { node['packages'].keys.include? "firewalld" }
end

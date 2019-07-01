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

execute 'firewall-rule' do
command '
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --reload '
only_if { node['packages'].keys.include? "firewalld" }
end

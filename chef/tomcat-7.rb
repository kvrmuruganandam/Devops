#
# Cookbook Name:: tomcat-7
# Recipe:: default
#
#
#Tomcat Installation 

package %w'tomcat tomcat-webapps tomcat-admin-webapps' do
action :install
end

service 'tomcat' do
action :restart
end

execute 'firewall-rule' do
command '
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload '
only_if { node['packages'].keys.include? "firewalld" }
end


#
# Cookbook Name:: tomcat-8
# Recipe:: default
#
#
#Tomcat Installation 


execute 'tomcat' do
command '
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
'
end

execute 'firewall-rule' do
command '
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload
'
only_if { node['packages'].keys.include? "firewalld" }
end


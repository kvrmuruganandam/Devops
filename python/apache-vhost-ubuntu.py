
import os
import shutil

site = raw_input('Enter site name:')
os.makedirs("/var/www/"+site+"/httpdocs")
t="/var/www/"+site+"/httpdocs"
c=open("/var/www/"+site+"/httpdocs/index.html","w")
c.write("welcome to "+site)
c.close()
h=open("/etc/hosts","w")
h.write("192.168.1.160 "+site)
h.close()
s="/etc/apache2/sites-available/"+site+'.conf'
f=open(s,'w')
source = '/etc/apache2/sites-available/000-default.conf'
target = '/etc/apache2/sites-available/'+site+".conf"
shutil.copy(source, target)
b = open(s).read()
b = b.replace('localhost',site)
b=b.replace('/var/www/html',t)
f = open(s, 'w')
f.write(b)
f.close() 
os.system("a2ensite "+site)
os.system("systemctl reload apache2")

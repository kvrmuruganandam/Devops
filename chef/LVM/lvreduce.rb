#!/usr/bin/ruby
#
#
#LVreduce
print <<`EOF`	
. /home/anand/var 				
umount  $target                                 
e2fsck -ff /dev/$vg/$lv 			
resize2fs /dev/$vg/$lv $redsize  		
lvreduce -L -$redsize /dev/$vg/$lv <<EOH	
y
y
y
EOH
mount /dev/$vg/$lv $target			
EOF

#!/usr/bin/ruby
#
#
#
print <<`EOF`					
. /home/anand/var				#get variables from input file
umount $target					#unmount mount point	
lvremove /dev/$vg/$lv <<eoh			#remove logical volume
y
eoh
vgremove $vg <<eoh				#remove volume group
y
eoh
pvremove /dev/$disk1				#remove physical volume
. /home/anand/var				#get variables from input file
sed -i "/\/dev\/$vg/ { N; d; }" /etc/fstab	#remove fstab entry
fdisk /dev/$disk <<eoh				#delete partition
d
w
eoh
EOF

#!/usr/bin/ruby
#
#
#
print <<`EOF`
. /home/anand/var                                             #run script to get variables from input file
fdisk /dev/$disk <<EOH                                        #Disk mount
$b                                                            #variables of input another file
EOH
. /home/anand/var                                             #get variables from input file
pvcreate /dev/$disk1                                          #physical volume creation
vgcreate $vg /dev/$disk1                                      #volume group creation
lvcreate -L +$size -n $lv $vg                                 #logical volume creation
mkfs.$type /dev/$vg/$lv                                       #formatting logical volume
mount /dev/$vg/$lv $target                                    #mount logical volume to mount point
echo "/dev/$vg/$lv $target $type defaults 0 0" >> /etc/fstab  #entry for permanent mount
mount -a                                                      #mount all device in fstab
df -h                                                         #verify mount point
EOF


#!/usr/bin/ruby
#
#
#
print <<`EOF`
$location
lvextend -L +$extsize /dev/$vg/$lv 		#extend logical volume
resize2fs /dev/$vg/$lv				#resize logical volume
EOF

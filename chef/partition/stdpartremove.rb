print <<`eof`
. $location
if [ "$Num" -eq 1 ]
then
fdisk /dev/$disk <<eoh
d
$vol
w
eoh
elif [ "$Num" -eq 2 ]
then
fdisk /dev/$disk <<eoh
d
$vol
d
$vol1
w
eoh
elif [ "$Num" -eq 3 ]
then
fdisk /dev/$disk <<eoh
d
$vol
d
$vol1
d
$vol2
w
eoh
else
fdisk /dev/$disk <<eoh
d
$vol
d
$vol1
d
$vol2
d
$vol3
w
fi
eoh


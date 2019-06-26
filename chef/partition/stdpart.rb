#!/usr/bin/ruby
#standard partition creation
print <<`eof`
. $location
if [ $Num -eq 1 ]
then
fdisk /dev/$b <<EOH
n
p
1

+$First
t
83
w
EOH
elif [ $Num -eq 2 ]
then
. $location
    fdisk /dev/$b <<EOH
n
p
1

+$First
t
83
n
p
2

+$Second
t
2
83
w
EOH
elif [ $Num -eq 3 ]
then
. $location
   fdisk /dev/$b <<EOH
n
p
1

+$First
t
83
n
p
2

+$Second
t
2
83
n
p
3

+$Third
t
83
w
EOH
else
. $location
fdisk /dev/$b <<EOH
n
p
1

+$First
t
83
n
p
2

+$Second
t
2
83
n
p
3

+$Third
t
83
n
p
4

+$Fourth
t
83
w
EOH
fi
eof

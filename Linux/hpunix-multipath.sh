#! /bin/bash
untar_logs(){
#To Get Log files as List
VAR_LOG_FILES=`ls -I $(basename $0) -I test|tr "\n" " "`
for file in $VAR_LOG_FILES
do
#To Extract tar.gz files
echo $file|grep "tar.gz" > /dev/null 2>&1
if [ $? -eq '0' ]
then
tar xvf $file;rm -rf $file
fi
#To Extract tar.Z files
echo $file|grep "tar.Z" > /dev/null 2>&1
if [ $? -eq '0' ]
then
VAR_SERVER_NAME=`echo $file|cut -d'-' -f1`
uncompress *.tar.Z > /dev/null 2>&1;tar xvf *.tar > /dev/null 2>&1;rm -rf *.tar > /dev/null 2>&1
VAR_DIR=`ls|grep $VAR_SERVER_NAME`
VAR_CHECK=`ls $VAR_DIR|wc -l`
if [ $VAR_CHECK -eq '1' ]
then
mv $VAR_DIR/./* $VAR_DIR/
fi
fi
#To Extract zip files
echo $file|grep "zip" > /dev/null 2>&1
if [ $? -eq '0' ]
then
VAR_DIRNAME=`echo $file|cut -d'.' -f1`;mkdir $VAR_DIRNAME;unzip $file -d $VAR_DIRNAME/;rm -rf $file
fi
done
}

lvm_details(){
VAR_VG_COUNT=`cat $j/lvm*/vgdisplay_-v.txt |grep -i "vg name"|awk '{print $3}'|sort|uniq|wc -l`
VAR_COUNT=1
VAR_TOTAL_LINE=`cat $j/lvm*/vgdisplay_-v.txt |wc -l`
for i in `seq $VAR_VG_COUNT`
do
if [ $i != $VAR_VG_COUNT ]
then
VAR_LINE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "VG name" | grep -i -B 9999 -m2 "Vg name"|wc -l`
VAR_VG_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "vg name" | grep -i -B 9999 -m2 "vg name"|grep -i "VG name"|head -1|awk '{print $3}'|sort|uniq`
VAR_PV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "vg name" | grep -i -B 9999 -m2 "Vg name"|grep -i "pv name"|grep -iv "Alternate Link"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_LV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "Vg name" | grep -i -B 9999 -m2 "Vg name"|grep -i "lv name"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_PE_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "Vg name" | grep -i -B 9999 -m2 "Vg name"|grep -i "PE Size"|awk '{print $4}'`

VAR_VGTOT_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "Vg name" | grep -i -B 9999 -m2 "Vg name"|grep -i "Total PE"|awk '{print $3}'|head -1|awk '{$1=$1};1'|tr -d "<>"`
VAR_VGTOT_SIZE=`expr $VAR_VGTOT_SIZE \* $VAR_PE_SIZE`

VAR_VG_FREE_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |grep -i -A 9999 "Vg name" | grep -i -B 9999 -m2 "Vg name"|grep -i "Free PE"|awk '{print $3}'|head -1|awk '{$1=$1};1'|tr -d "<>"`

VAR_VG_FREE_SIZE=`expr $VAR_VG_FREE_SIZE \* $VAR_PE_SIZE`
VAR_COUNT=`expr 0 + $VAR_COUNT + $VAR_LINE`

else

#VAR_COUNT=`expr 0 + $VAR_COUNT + $VAR_LINE - 1`
VAR_VG_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |sed -n '/VG Name/,$p'|grep -i "VG name"|awk '{print $3}'|sort|uniq`
VAR_PV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |sed -n '/VG Name/,$p'|grep -i "PV name"|grep -iv "Alternate Link"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_LV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |sed -n '/VG Name/,$p'|grep -i "lv name"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_PE_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |sed -n '/VG Name/,$p'|grep -i "PE Size"|awk '{print $4}'`

VAR_VGTOT_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |sed -n '/VG Name/,$p'|grep -i "Total PE"|awk '{print $3}'|head -1|awk '{$1=$1};1'|tr -d "<>"`

VAR_VGTOT_SIZE=`expr $VAR_VGTOT_SIZE \* $VAR_PE_SIZE `
VAR_VG_FREE_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm*/vgdisplay_-v.txt |sed -n '/VG Name/,$p'|grep -i "Free PE"|awk '{print $3}'|head -1|awk '{$1=$1};1'|tr -d "<>"`
VAR_VG_FREE_SIZE=`expr $VAR_VG_FREE_SIZE \* $VAR_PE_SIZE`
fi
echo "$VAR_HOSTNAME,$VAR_VG_NAME,$(echo $VAR_VGTOT_SIZE|awk '{$1=$1/1024; print $1;}'|awk '{printf "%.0f\n", $1}'),$(echo $VAR_VG_FREE_SIZE|awk '{$1=$1/1024; print $1;}'|awk '{printf "%.0f\n", $1}'),$VAR_PV_NAME,$VAR_LV_NAME" >> b.csv
done
}

host_details(){
rm -rf output.csv 2> /dev/null
VAR_UNTARFILE_NAME=`ls -d */|tr -d '/'|tr '\n' ' '`
echo "HOSTNAME,ARRAY,CAPACITY(GB),MULTIPATH DISK,MPATH NAME" > hp-ux-multipath.csv
echo "HOSTNAME,VG NAME,VG TOTAL SIZE(GB),VG FREE SIZE(GB),PV NAME,LV NAME" > hp-ux-lvm.csv
for j in $VAR_UNTARFILE_NAME
do

unset VAR_HOSTNAME
unset VAR_WWN_LIST
unset VAR_MPATH_DISK_LIST
unset VAR_DISK_NAME
unset VAR_MPATH
unset VAR_DISK_CAPACITY
unset VAR_ARRAY_LIST


VAR_HOSTNAME=`cat $j/host/hostname.txt|tail -1`
VAR_WWN_LIST=`sed -n '/WWN/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|awk '{print $3}'|sort|uniq|tr '\n' ' '`
for wwn in $VAR_WWN_LIST
do
grep "$wwn" $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|rev|cut -d'/' -f1|rev|grep -i "^d" > /dev/null 2>&1
if [ $? -eq '0' ]
then
VAR_MPATH_NAME=`grep "$wwn" $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|rev|cut -d'/' -f1|rev|grep -i "^c"|tr '\n' ' '`
VAR_DISK_NAME=`grep "$wwn" $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|rev|cut -d'/' -f1|rev|grep -v "^c"|tr '\n' ' '`
else
VAR_MPATH_NAME=`grep "$wwn"  $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|rev|cut -d'/' -f1|rev|tr '\n' ' '`
VAR_DISK_NAME=`grep "$wwn"  $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|rev|cut -d'/' -f1|rev|head -1`
fi
VAR_DISK_CAPACITY=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|awk '{print $7}'|awk '{print $1/1024/1024}'|awk '{printf "%.2f\n",$1}'`
VAR_ARRAY_LIST=`sed -n '/Array/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|grep -wi "$VAR_DISK_NAME"|awk '{print $2}'|sort|uniq|tr '\n' ' '`
echo $VAR_HOSTNAME,$VAR_ARRAY_LIST,$VAR_DISK_CAPACITY,$VAR_DISK_NAME,$VAR_MPATH_NAME >> a.csv
done
lvm_details
done
sed -e 's/\r//g' a.csv|awk '{$1=$1};1' >> hp-ux-multipath.csv
sed -e 's/\r//g' b.csv|awk '{$1=$1};1' >> hp-ux-lvm.csv
ssconvert --merge-to=output-hp-ux.xlsx hp-ux-multipath.csv hp-ux-lvm.csv > /dev/null 2>&1
rm -rf hp-ux-multipath.csv hp-ux-lvm.csv a.csv b.csv 
}

########################
# MAIN
########################
ls|grep tar > /dev/null 2>&1
if [ $? -eq '0' ]
then
untar_logs
fi
host_details

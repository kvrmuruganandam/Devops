
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
VAR_VG_COUNT=`cat  $j/lvm_linux/vgdisplay_-v.txt |grep -i "vg name"|awk '{print $3}'|sort|uniq|wc -l`
VAR_COUNT=1
VAR_TOTAL_LINE=`cat $j/lvm_linux/vgdisplay_-v.txt |wc -l`
for i in `seq $VAR_VG_COUNT`
do
if [ $i != $VAR_VG_COUNT ]
then
VAR_LINE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |grep -i -A 9999 "Volume Group" | grep -i -B 9999 -m2 "Volume Group"|wc -l`
VAR_VG_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |grep -i -A 9999 "Volume Group" | grep -i -B 9999 -m2 "Volume Group"|grep -i "VG name"|awk '{print $3}'|sort|uniq`
VAR_PV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |grep -i -A 9999 "Volume Group" | grep -i -B 9999 -m2 "Volume Group"|grep -i "pv name"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_LV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |grep -i -A 9999 "Volume Group" | grep -i -B 9999 -m2 "Volume Group"|grep -i "lv path"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_VGTOT_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |grep -i -A 9999 "Volume Group" | grep -i -B 9999 -m2 "Volume Group"|grep -i "vg size"|awk '{print $3 $4}'|tr -d "<>"`

VAR_VG_FREE_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |grep -i -A 9999 "Volume Group" | grep -i -B 9999 -m2 "Volume Group"|grep -i "Free  PE / Size"|awk -F/ '{print $3 $4}'|awk '{$1=$1};1'|tr -d "<>"`
VAR_COUNT=`expr 0 + $VAR_COUNT + $VAR_LINE`
else
VAR_VG_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |sed -n '/Volume group/,$p'|grep -i "VG name"|awk '{print $3}'|sort|uniq`
VAR_PV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |sed -n '/Volume group/,$p'|grep -i "PV name"|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_LV_NAME=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |sed -n '/Volume group/,$p'|grep -i "lv path"|awk '{print $3}'|sort|uniq|tr '\n' ' '`

VAR_VGTOT_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |sed -n '/Volume group/,$p'|grep -i "vg Size"|awk '{print $3 $4}'|awk '{$1=$1};1'|tr -d "<>"`
VAR_VG_FREE_SIZE=`sed -n "$VAR_COUNT,$VAR_TOTAL_LINE p" $j/lvm_linux/vgdisplay_-v.txt |sed -n '/Volume group/,$p'|grep -i "Free  PE / Size"|awk -F/ '{print $3 $4}'|awk '{$1=$1};1'|tr -d "<>"`

fi
echo "$VAR_HOSTNAME,$VAR_VG_NAME,$VAR_VGTOT_SIZE,$VAR_VG_FREE_SIZE,$VAR_PV_NAME,$VAR_LV_NAME" >> b.csv
done
}

host_details(){
rm -rf output.csv 2> /dev/null
VAR_UNTARFILE_NAME=`ls -d */|tr -d '/'|tr '\n' ' '`
echo "HOSTNAME,ARRAY,MULTIPATH DISK,LUN ID,CAPACITY(GB),MPATH NAME,MPATH DEVICE" > linux-multipath.csv
echo "HOSTNAME,VG NAME,VG TOTAL SIZE,VG FREE SIZE,PV NAME,LV NAME" > linux-lvm.csv
for j in $VAR_UNTARFILE_NAME
do

unset VAR_HOSTNAME
unset VAR_WWN_LIST
unset VAR_MPATH
unset VAR_MPATH_NAME
unset VAR_PV_NAME
unset VAR_VG_NAME
unset VAR_LV_NAME
unset VAR_DISK_CAPACITY
unset VAR_DISK_NAME
unset VAR_ARRAY_LIST



VAR_HOSTNAME=`cat $j/host/hostname.txt|tail -1`
VAR_WWN_LIST=`sed -n '/WWN/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|awk '{print $3}'|sort|uniq|tr '\n' ' '`
for wwn in $VAR_WWN_LIST
do
VAR_MPATH_DISK_LIST=`grep "$wwn"  $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|grep -v "dm-"|tr '\n' ' '`
VAR_LUN_ID=""
for id in $VAR_MPATH_DISK_LIST
do
	VAR_LUN=`grep -wi "$id" $j/host/multipath_-ll.txt|awk '{print $2}'`
	VAR_LUN_ID="$VAR_LUN_ID$VAR_LUN "
done
VAR_MPATH=`grep "$wwn"  $j/inq/*no_dots_-hds_wwn.txt|awk '{print $1}'|sed 's/\/dev\///g'|grep -i "dm-"`
VAR_MPATH_NAME=`cat $j/host/multipath_-ll.txt |grep -wi "$VAR_MPATH"|awk '{print $1}'`
#VAR_PV_NAME=`cat $j/lvm_linux/pvscan_-v.txt |grep -wi "$VAR_MPATH_NAME"|sed -n 's/.*PV//p'|awk '{print $1}'`
#VAR_VG_NAME=`cat $j/lvm_linux/pvscan_-v.txt |grep -wi "$VAR_MPATH_NAME"|sed -n 's/.*VG//p'|awk '{print $1}'`
#if [ ! -z $VAR_VG_NAME ]
#then
#VAR_LV_NAME=`cat $j/lvm_linux/vgdisplay_-v.txt |grep -wi "$VAR_VG_NAME"|grep -wi "Lv path"|awk '{print $NF}'|tr '\n' '\t'`
#else
#	VAR_LV_NAME=""
#fi
VAR_DISK_NAME=`grep -w $wwn $j/inq/*no_dots_-hds_wwn.txt|head -1|awk '{print $1}'`
VAR_DISK_CAPACITY=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|awk '{print $7}'|awk '{print $1/1024/1024}'|awk '{printf "%.2f\n",$1}'`
VAR_ARRAY_LIST=`sed -n '/Array/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|grep -wi "$VAR_DISK_NAME"|awk '{print $2}'|sort|uniq|tr '\n' ' '`
echo $VAR_HOSTNAME,$VAR_ARRAY_LIST,$VAR_MPATH_DISK_LIST,$VAR_LUN_ID,$VAR_DISK_CAPACITY,$VAR_MPATH_NAME,$VAR_MPATH >> a.csv
done
lvm_details
done
sed -e 's/\r//g' a.csv|awk '{$1=$1};1' >> linux-multipath.csv
sed -e 's/\r//g' b.csv|awk '{$1=$1};1' >> linux-lvm.csv
ssconvert --merge-to=output-linux.xlsx linux-multipath.csv linux-lvm.csv > /dev/null 2>&1
rm -rf linux-multipath.csv linux-lvm.csv a.csv b.csv 
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

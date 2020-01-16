#!/bin/bash
######################################################################
# **************************************************                 
# ***       Windows Host Details                   ***               
# **************************************************                
# Script Name           :       "Windows.sh"
# Author                :       "Muruganandam"                             
# Version               :       "1.0"                               
# Run Script            :       "./Windows.sh"
#
# *********************************************
# ***            Description                ***
# *********************************************
# When you run the script, it will unzip log files and collect host details like Hostname,OS,Capacity,HBA Name,Node and Port WWN,Speed,Array list.
#
#
# *********************************************
# ***            NOTE                       ***
# *********************************************
# before run script make sure you have only log files and script file in current directory... 
#

######################################
# UNCOMPRESS LOG FILES
######################################

un_zip_logs(){
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


#####################################
# HOST DETAILS
#####################################

host_details(){

#To get log files
VAR_LOG_LIST=`ls -d */|tr -d '/'|tr '\n' ' '`

#To get storage array file
VAR_ARRAY_FILE=`ls|grep -i *Array-List.csv`

for i in $VAR_LOG_LIST
do
unset VAR_HOSTNAME
unset VAR_OSVERSION
unset VAR_TOTAL_DISK_CAPACITY
unset VAR_ARRAY
unset VAR_ARRAY_STATUS
unset VAR_HBA_NAME
unset VAR_FIRMWARE_VERSION
unset VAR_HBA_DRIVER
unset VAR_NODE_WWN
unset VAR_PORT_WWN
unset VAR_SPEED
unset VAR_STORAGE_ARRAY_LIST

#To get hostname
VAR_HOSTNAME=`cat $i/*SERVER_BRIEF.TXT|grep -i "Server Brief for"|awk '{print $4}'`

#To get cluster name
VAR_CLUSTER=`cat $i/CLUSTER/*MPS_INFORMATION.TXT 2>/dev/null|grep -i "cluster name"|head -1|awk '{print $4}'|sed -e 's/\r//g'`

#To get host os
VAR_OS=`cat $i/*SERVER_BRIEF.TXT|grep -i "os version"|awk -F":" '{print $2}'|tr -s " "|tr -d ","|sed -e 's/\r//g'|awk '{$1=$1};1'`

#To get disk capacity
VAR_CAPACITY_LIST=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|awk -F":" '{print $6}'|grep -vi "n/a"|tr ':' ' '|tr '\n' ' '`
VAR_TOTAL_DISK_CAPACITY=0
for disk_size in $VAR_CAPACITY_LIST
do
VAR_TOTAL_DISK_CAPACITY=`expr $VAR_TOTAL_DISK_CAPACITY + $disk_size`
done

#To get array list
VAR_ARRAY=`sed -n '/ARRAY/,$p' $i/INQ/*MAPINFO.TXT|sed 1,3d |grep -i "open-v"|awk -F":" '{print $5}'|awk '{$1=$1;print}'|sort|uniq|tr '\n' '|'`

#To get hba name
VAR_HBA_NAME=`cat $i/INQ/*MAPINFO.TXT|grep -i "hba name:"|awk -F" " '{print $3}'|tr '\n' ' '`

#To get firmware version
VAR_FIRMWARE_VERSION=`cat $i/INQ/*MAPINFO.TXT|grep -i "firmware version:"|awk -F" " '{print $3}'|tr '\n' '|'|tr -d ";,"`

#To get driver version
VAR_DRIVER_VERSION=`cat $i/INQ/*MAPINFO.TXT|grep -i "driver version:"|awk -F" " '{print $3}'|tr '\n' '|'|tr -d ";,"`

#To get node wwn
VAR_NODE_WWN=`cat $i/INQ/*MAPINFO.TXT|grep -i "node wwn:" |awk -F" " '{print $3}'|tr '\n' '|'`

#To ge port wwn
VAR_PORT_WWN=`cat $i/INQ/*MAPINFO.TXT|grep -i "port wwn:" |awk -F" " '{print $3}'|tr '\n' '|'`

#To get port speed
VAR_SPEED=`cat $i/INQ/*MAPINFO.TXT|grep -i "port speed:"|awk -F" " '{print $3}'|tr '\n' '|'`

#To get total disk capacity
VAR_TOTAL_DISK_CAPACITY=`echo $VAR_TOTAL_DISK_CAPACITY|awk '{$1=$1/1024/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`

#To check host array with storage array
#VAR_CHECK_LIST_ARRAY=`echo $VAR_ARRAY|tr -d '|'`
#if [ ! -z $VAR_CHECK_LIST_ARRAY ]
#then
#for arr in `echo $VAR_ARRAY|tr '|' ' '` 
#do
#b=0
#c=0
#grep $arr $VAR_ARRAY_FILE > /dev/null 2>&1
#if [ $? = '0' ]
#then
#a=0
#else
#b=1
#fi
#c=`expr $a + $b + $c`
#done
#if [ $c -eq '0' ]
#then
#VAR_ARRAY_STATUS="Matched"
#else
#VAR_ARRAY_STATUS="Not Matched"
#fi
#else
#VAR_ARRAY_STATUS="Not Matched"
#fi

for pwwn in `echo $VAR_PORT_WWN|tr '|' ' '`
do
grep -i "$pwwn" $VAR_ARRAY_FILE|awk -F, '{print $1}' >> array
done

for mcheck in `echo $VAR_ARRAY|tr '|' ' '`
do
grep -i "$mcheck" array > /dev/null 2>&1
if [ $? -eq '0' ]
then
VAR_ARRAY_STATUS="Matched"
else
VAR_ARRAY_STATUS="Not Matched"
fi
done

VAR_STORAGE_ARRAY_LIST=`cat array|sort|uniq|tr '\n' '|'`
rm -rf array

VAR_DISK_LIST=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|awk -F":" '{print $1}'|tr -d '\\\.'|tr '\n' ' '`
VAR_COUNT_VOL=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|awk -F":" '{print $1}'|tr -d '\\\.'|wc -l`
VAR_COUNT_LEAST=`expr $VAR_COUNT_VOL - 1`
VAR_MIN=1
for disk in $VAR_DISK_LIST
do
VAR_DISKNUM=`echo $disk|grep -Eo '[0-9]{1,4}'`
if [ $VAR_MIN -ne $VAR_COUNT_VOL ]
then
cat $i/HOST/*DSKPART_VOLS.TXT|grep -i -A 9999 "disk $VAR_DISKNUM"|grep -i -A 9999 "volume ###"|grep -i -B 9999 -m2 "Volume ###"|grep -i "volume"|grep -iv "###"|awk '{print $1" "$2","$3","$4" "$5}'|sed 's/NTFS//g'|sed 's/FAT32//g' > vol

VAR_LUN_ID=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|grep -i $disk|awk -F":" '{print $9}'|sed -e 's/\r//g'|awk '{$1=$1};1'`
VAR_DISK_CAP=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|grep -i $disk|awk -F":" '{print $6}'|sed -e 's/\r//g'|awk '{$1=$1};1'|awk '{$1=$1/1024/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`
VAR_LUN_STATUS=`cat $i/HOST/*DSKPART_VOLS.TXT|grep -i -A 9999 "disk $VAR_DISKNUM"|grep -i -A 9999 "volume ###"|grep -i -B 9999 -m2 "Volume ###"|grep -iv "###"|grep -i "status"|awk -F: '{print $2}'|sed -e 's/\r//g'|awk '{$1=$1};1'`
echo "$VAR_HOSTNAME,$disk,$VAR_DISK_CAP,$VAR_LUN_ID,$VAR_LUN_STATUS" > b
paste -d","  b vol >> c.csv

else
VAR_LUN_ID=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|grep -i $disk|awk -F":" '{print $9}'|sed -e 's/\r//g'|awk '{$1=$1};1'`
VAR_DISK_CAP=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep -i "open-v"|grep -i $disk|awk -F":" '{print $6}'|sed -e 's/\r//g'|awk '{$1=$1};1'|awk '{$1=$1/1024/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`
VAR_LUN_STATUS=`cat $i/HOST/*DSKPART_VOLS.TXT|grep -i -A 9999 "disk $VAR_DISKNUM"|grep -i -A 9999 "volume ###"|grep -iv "###"|grep -i "status"|awk -F: '{print $2}'|sed -e 's/\r//g'|awk '{$1=$1};1'`
cat $i/HOST/*DSKPART_VOLS.TXT|grep -i -A 9999 "disk $VAR_DISKNUM"|grep -i -A 9999 "volume ###"|grep -i "volume"|grep -iv "###"|awk '{print $1" "$2","$3","$4" "$5}'|sed 's/NTFS//g'|sed 's/FAT32//g' > vol

echo "$VAR_HOSTNAME,$disk,$VAR_DISK_CAP,$VAR_LUN_ID,$VAR_LUN_STATUS" > b
paste -d","  b vol >> c.csv

fi
VAR_MIN=`expr 1 + $VAR_MIN`
done


#To get final report
echo "$VAR_HOSTNAME,$VAR_CLUSTER,$VAR_OS,$VAR_TOTAL_DISK_CAPACITY,$VAR_ARRAY,$VAR_STORAGE_ARRAY_LIST,$VAR_ARRAY_STATUS,$VAR_HBA_NAME,$VAR_FIRMWARE_VERSION,$VAR_DRIVER_VERSION,$VAR_NODE_WWN,$VAR_PORT_WWN,$VAR_SPEED" >> a.csv
done
echo "HOSTNAME,CLUSTER,OS,CAPACITY(GB),HOST ARRAY LIST,STORAGE ARRAY LIST,ARRAY STATUS,HBA_NAME,FIRMWARE VERSION,DRIVER VERSION,NODE_WWN,PORT_WWN,SPEED" > windows.csv
echo "HOSTNAME,DISK NAME,CAPACITY (GB),LUN ID,STATUS,VOLUME NUMBER,DRIVE LETTER,LABEL" > disk-details.csv
sort a.csv |uniq >> windows.csv
cat c.csv >> disk-details.csv

ssconvert --merge-to=output-windows.xlsx windows.csv disk-details.csv > /dev/null 2>&1
rm -rf a.csv b.csv windows.csv disk-details.csv c.csv b vol
}


###################
# MAIN
###################

#To check storage array file exist or not
ls|grep *Array-List.csv > /dev/null 2>&1
if [ $? -eq '0' ]
then

#to check log files are compressed or not
ls|grep zip
if [ $? -eq '0' ]
then
un_zip_logs
fi
host_details
else
echo "Please make sure storage array list file is present here..."
fi

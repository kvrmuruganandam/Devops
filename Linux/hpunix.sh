#!/bin/bash
######################################################################
# **************************************************                 
# ***    Hpunix Host Details                     ***               
# **************************************************                
# Script Name           :       "hpunix.sh"
# Author                :       "Muruganandam"                                  
# Version               :       "1.0"                                  
# Run Script            :       "./hpunix.sh"
#
# *********************************************
# ***            Description                ***
# *********************************************
# When you run the script, it will untar log files and collect host details like Hostname,OS,Capacity,HBA Name,Node and Port WWN,Speed,Array list.
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
uncompress $file > /dev/null 2>&1;VAR_FILE_NAME=`echo $file|rev|cut -c3-|rev`;tar xvf $VAR_FILE_NAME > /dev/null 2>&1;rm -rf $VAR_FILE_NAME
fi

#To Extract tar files
echo $file|grep "tar$" > /dev/null 2>&1
if [ $? -eq '0' ]
then
tar xvf $file;rm -rf $file
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

#To get log file name
VAR_UNTARFILE_NAME=`ls -d */|tr -d '/'|tr '\n' ' '`

#To get storage array file
VAR_ARRAY_FILE=`ls|grep -i *Array-List.csv`

for j in $VAR_UNTARFILE_NAME
do

unset VAR_HOSTNAME
unset VAR_OSVERSION
unset VAR_TOTAL_DISK_CAPACITY
unset VAR_ARRAY_LIST
unset VAR_ARRAY_STATUS
unset VAR_HBA_NAME
unset VAR_FIRMWARE_VERSION
unset VAR_HBA_DRIVER
unset VAR_NODE_WWN
unset VAR_PORT_WWN
unset VAR_SPEED
unset VAR_STORAGE_ARRAY_LIST

#To get emcgrab file
VAR_EMC_FILE=`ls $j|grep -i "emcgrab" 2>/dev/null`
grep  "Hostname" $j/$VAR_EMC_FILE > /dev/null 2>&1
if [ $? -eq '0' ]
then

#To get hostname
VAR_HOSTNAME=`grep  "Hostname" $j/$VAR_EMC_FILE |tr -s " "|awk -F":" '{print $2}'|cut -d'/' -f1`
else
VAR_HOSTNAME=`cat $j/host/hostname.txt|tail -1`
fi

#To get host os version
VAR_OSVERSION=`cat $j/emcgrab*|grep -i "operating system"|awk '{print $4" "$5}'`

#To get hba name
VAR_HBA_NAME=`cat $j/inq/*hba.txt|grep -i "hba name:" |awk -F" " '{print $3}'|tr '\n' '|'`

#To get node wwn
VAR_NODE_WWN=`cat $j/inq/*hba.txt|grep -i "node wwn:" |awk -F" " '{print $3}'|tr '\n' '|'`

#To get port wwn
VAR_PORT_WWN=`cat $j/inq/*hba.txt|grep -i "port wwn:" |awk -F" " '{print $3}'|tr '\n' '|'`

#To get port speed
VAR_SPEED=`cat $j/inq/*hba.txt|grep -i "port speed:" |awk -F" " '{print $3}'|tr '\n' '|'`

#To get firmware version
VAR_FIRMWARE_VERSION=`cat $j/inq/*hba.txt|grep -i "firmware version"|awk -F: '{print $2}'|tr '\n' '|'|tr -d ";,"|awk '{$1=$1;print}'`

#To get driver version
VAR_DRIVER_VERSION=`cat $j/inq/*hba.txt|grep -i "driver version"|awk -F: '{print $2}'|sed -n 's/.*Driver//p'|awk '{print $1}'|tr '\n' '|'|tr -d ";,"|awk '{$1=$1;print}'`

#To get wwn list
VAR_WWN_LIST=`cat $j/inq/*hds_wwn.txt|sed -n '/WWN/,$p'| sed 1,2d|awk '{print $3}'|sort|uniq|tr '\n' ' '`

#To get array list
VAR_ARRAY_LIST=`sed -n '/Array/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|awk '{print $2}'|sort|uniq|tr '\n' '|'`

#To get disk capacity
VAR_TOTAL_DISK_CAPACITY=0
for k in $VAR_WWN_LIST
do

#To get disk name
VAR_DISK_NAME=`grep -w $k $j/inq/*hds_wwn.txt|head -1|awk '{print $1}'`

#To check disk from open-v or not
VAR_OPENV_CHECK=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|grep -w OPEN-V`
if [ $? -eq '0' ]
then

#To get disk capacity
VAR_DISK_CAPACITY=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|awk '{print $7}'`
VAR_TOTAL_DISK_CAPACITY=`expr $VAR_TOTAL_DISK_CAPACITY + $VAR_DISK_CAPACITY`
fi
done
VAR_TOTAL_DISK_CAPACITY=`echo $VAR_TOTAL_DISK_CAPACITY|awk '{$1=$1/1024/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`

#VAR_CHECK_LIST_ARRAY=`echo $VAR_ARRAY_LIST|tr -d '|'`
#if [ ! -z $VAR_CHECK_LIST_ARRAY ]
#then
#To ensure host connected from respective array
#for arr in `echo $VAR_ARRAY_LIST|tr '|' ' '` 
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

for mcheck in `echo $VAR_ARRAY_LIST|tr '|' ' '`
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
#To get final report
echo $VAR_HOSTNAME,$VAR_OSVERSION,$VAR_TOTAL_DISK_CAPACITY,$VAR_ARRAY_LIST,$VAR_STORAGE_ARRAY_LIST,$VAR_ARRAY_STATUS,$VAR_HBA_NAME,$VAR_FIRMWARE_VERSION,$VAR_DRIVER_VERSION,$VAR_NODE_WWN,$VAR_PORT_WWN,$VAR_SPEED >> a.csv
done
echo "HOSTNAME,OS,CAPACITY(GB),HOST ARRAY LIST,STORAGE ARRAY LIST,ARRAY STATUS,HBA NAME,FIRMWARE VERSION,DRIVER VERSION,NODE_WWN,PORT_WWN,SPEED" > output-hpunix.csv
sort a.csv |uniq >> output-hpunix.csv
rm -rf a.csv
}


########################
# MAIN
########################

#To check array list file exist or not
ls|grep *Array-List.csv > /dev/null 2>&1
if [ $? -eq '0' ]
then

#To check log file are compressed or not
ls|grep tar > /dev/null 2>&1
if [ $? -eq '0' ]
then
untar_logs
fi
host_details
else
echo "Please make sure storage array list file is present here..."
fi


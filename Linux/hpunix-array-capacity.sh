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
VAR_SERVER_NAME=`echo $file|cut -d'-' -f1`
uncompress .tar.Z > /dev/null 2>&1;tar xvf .tar > /dev/null 2>&1;rm -rf *.tar > /dev/null 2>&1
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
rm -rf output.csv 2> /dev/null
VAR_UNTARFILE_NAME=`ls -I $(basename "$0") |tr '\n' ' '`
echo "HOSTNAME,ARRAY LIST,ARRAY,CAPACITY" > output.csv
for j in $VAR_UNTARFILE_NAME
do
VAR_EMC_FILE=`ls $j|grep -i "emcgrab" 2>/dev/null`
if [ $? -eq '0' ]
then
VAR_HOSTNAME=`grep  "Hostname" $j/$VAR_EMC_FILE |tr -s " "|awk -F":" '{print $2}'|cut -d'/' -f1`
else
VAR_HOSTNAME=`cat $j/host/hostname.txt|tail -1`
fi
VAR_WWN_LIST=`cat $j/inq/*no_dots_-hds_wwn.txt|sed -n '/WWN/,$p'| sed 1,2d|awk '{print $3}'|sort|uniq|tr '\n' ' '`
VAR_ARRAY_LIST=`cat $j/inq/*no_dots_-hds_wwn.txt|sed -n '/WWN/,$p'| sed 1,2d|awk '{print $2}'|sort|uniq|tr '\n' ' '`
cat $j/inq/*no_dots.txt|sed -n '/DEVICE/,$p'| sed 1,2d|grep -wi "open-v"|awk '{print $1","$7}' > disk
for i in $VAR_WWN_LIST
do
grep -w $i $j/inq/*no_dots_-hds_wwn.txt|head -1|awk '{print $1","$2}' >> array
done

for a in $VAR_ARRAY_LIST
do
        VAR_DISK_LIST=`grep -w "$a" array|awk -F"," '{print $1}'|tr '\n' ' '`
        VAR_TOTAL_DISK_CAPACITY=0
for disk in $VAR_DISK_LIST
do     
       VAR_CAPACITY=`grep -wi "$disk" disk|head -1|awk -F"," '{print $2}'`
       VAR_TOTAL_DISK_CAPACITY=`expr $VAR_TOTAL_DISK_CAPACITY + $VAR_CAPACITY`
done
echo $VAR_HOSTNAME,$VAR_ARRAY_LIST,$a,$VAR_TOTAL_DISK_CAPACITY >> output.csv
done
rm array 
done
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

#!/bin/bash
######################################################################
# **************************************************                 
# ***       Solaris Host Details                   ***               
# **************************************************                
# Script Name           :       "solaris-disk-details.sh"
# Author                :       "Muruganandam"                                
# Version               :       "1.0"                                
# Run Script            :       "./solaris-disk-details.sh"
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
for j in $VAR_UNTARFILE_NAME
do
VAR_HOSTNAME=`cat $j/host/hostname.txt|tail -1`
VAR_WWN_LIST=`sed -n '/WWN/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|awk '{print $3}'|sort|uniq|tr '\n' ' '`
for i in $VAR_WWN_LIST
do
VAR_DISK_NAME=`grep -w $i $j/inq/*no_dots_-hds_wwn.txt|head -1|awk '{print $1}'`
VAR_DISK_CAPACITY=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|awk '{print $7}'`
echo $VAR_HOSTNAME,$VAR_DISK_NAME,$VAR_DISK_CAPACITY >> a.csv
done
done
echo "HOSTNAME,DISK NAME,CAPACITY" > output.csv
sort a.csv |uniq >> output.csv
rm -rf a.csv
}

########################
# MAIN
########################
ls|grep tar >/dev/null 2>&1
if [ $? -eq '0' ]
then
untar_logs
fi
host_details

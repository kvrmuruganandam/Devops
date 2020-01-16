#!/bin/bash
######################################################################
# **************************************************                 
# ***       Windows Host Details                   ***               
# **************************************************                
# Script Name           :       "Windows.sh"
# Author                :       "Muruganandam"                            
# Created Date          :       "2.10.2019"
# Latest Update         :       "9.10.2019"
# Copyright             :       "Copyright 2019, The ZENfra Project" 
# License               :       "VTG"                                
# Version               :       "1.0"                               
# Email                 :       "migrationteam@virtualtechgurus.com"    
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
rm -rf output-windows.csv 2> /dev/null
VAR_LOG_LIST=`ls -d */|tr -d '/'|tr '\n' ' '`
for i in $VAR_LOG_LIST
do
VAR_HOSTNAME=`cat $i/*SERVER_BRIEF.TXT|grep -i "Server Brief for"|awk '{print $4}'`

VAR_ARRAY_LIST=`sed -n '/ARRAY/,$p' $i/INQ/*MAPINFO.TXT|sed 1,3d |grep -i "open-v"|awk -F":" '{print $5}'|awk '{$1=$1;print}'|sort|uniq|tr '\n' ' '`

echo "HOSTNAME,TOTAL ARRAY,ARRAY NAME,CAPACITY(GB)" > output-windows.csv
for arr in $VAR_ARRAY_LIST
do
VAR_ARRAY_NAME=`echo $arr`
VAR_CAPACITY_LIST=`cat $i/INQ/*MAPINFO.TXT|sed -n '/ARRAY/,$p'|sed 1,3d |grep  "$arr"|awk -F":" '{print $6}'|tr '\n' ' '`

VAR_TOTAL_DISK_CAPACITY=0
for disk_size in $VAR_CAPACITY_LIST
do
VAR_TOTAL_DISK_CAPACITY=`expr $VAR_TOTAL_DISK_CAPACITY + $disk_size`
done
VAR_TOTAL_DISK_CAPACITY=`echo $VAR_TOTAL_DISK_CAPACITY|awk '{$1=$1/1024/1024; print $1;}'|awk '{printf "%d\n",$1}'`
echo "$VAR_HOSTNAME,$VAR_ARRAY_LIST,$VAR_ARRAY_NAME,$VAR_TOTAL_DISK_CAPACITY" >> a.csv
done
done
sort a.csv |uniq >> output-windows.csv
rm -rf a.csv
}


###################
# MAIN
###################
ls|grep zip
if [ $? -eq '0' ]
then
un_zip_logs
fi
host_details

#!/bin/bash
######################################################################
# **************************************************                 
# ***       Linux Host Details              	 ***               
# **************************************************                
# Script Name           :       "linux.sh"
# Author                :       "Muruganandam"                               
# Version               :       "1.0"                                 
# Run Script            :       "./linux.sh"
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
#  HOST DETAILS
#####################################


host_details(){

#To get current directory log files
VAR_UNTARFILE_NAME=`ls -d */|tr -d '/'|tr '\n' ' '`

#To get storage array list file name
VAR_ARRAY_FILE=`ls|grep -i *Array-List.csv`


for j in $VAR_UNTARFILE_NAME
do

unset VAR_HOSTNAME
unset VAR_OSVERSION
unset VAR_ARRAY_LIST
unset VAR_ARRAY_STATUS
unset VAR_TOTAL_DISK_CAPACITY
unset VAR_HBA_TYPE
unset VAR_DESCRIPTION
unset VAR_HBA_MODEL
unset VAR_FIRMWARE_VERSION
unset VAR_HBA_DRIVER
unset VAR_SPEED
unset VAR_HBA_NAME
#unset VAR_HBA_FABRIC_NAME
#unset VAR_HBA_SERIAL_NUMBER
unset VAR_PORT_WWN
unset VAR_NODE_WWN
unset VAR_STORAGE_ARRAY_LIST
unset VAR_MULTIPATH_VERSION
unset VAR_SHOST_LIST

#To get hostname
VAR_HOSTNAME=`cat $j/host/hostname.txt|tail -1`

#To get host os version
VAR_OSVERSION=`cat $j/host/etc/redhat-release|tail -1|cut -d'(' -f1`

#To get scsi host max lun count
VAR_SHOST_LIST=`ls $j/host/sys/class/scsi_host`
VAR_LUN_LIST=""
for i in $VAR_SHOST_LIST
do
VAR_LUN_FILE=`ls $j/host/sys/class/scsi_host/$i/|grep "max_luns$"`
if [ $? -eq '0' ]
then
VAR_NLUN=`cat $j/host/sys/class/scsi_host/$i/$VAR_LUN_FILE`
VAR_LUN_LIST="$VAR_LUN_LIST$VAR_NLUN "
fi
done



#To verify inq folder eexist or not
cat $j/inq/*hba.txt|grep -i "hba name:" > /dev/null 2>&1
if [ $? -eq '0' ]
then

#To get hba name 
VAR_HBA_NAME=`cat $j/inq/*hba.txt|grep -i "hba name:"|awk -F" " '{print $3}'|tr '\n' '|'`

#To get hba type
#VAR_HBA_TYPE=`cat $j/inq/*hba.txt|grep -i "hba type:"|awk -F" " '{print $3,$NF}'|tr '\n' '|'`

#To get node wwn 
VAR_NODE_WWN=`cat $j/inq/*hba.txt|grep -i "node wwn:"|awk -F" " '{print $3}'|tr '\n' '|'`

#To get port wwn
VAR_PORT_WWN=`cat $j/inq/*hba.txt|grep -i "port wwn:"|awk -F" " '{print $3}'|tr '\n' '|'`

#To get port speed
VAR_SPEED=`cat $j/inq/*hba.txt|grep -i "port speed:"|awk -F" " '{print $3}'|tr '\n' '|'`

#To get model description of hba
VAR_DESCRIPTION=`cat $j/hbainfo/hbainfo.txt |grep  -i  "model description"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ";,"`

#To get firmware version
VAR_FIRMWARE_VERSION=`cat $j/inq/*hba.txt|grep  -i  "firmware"|awk -F: '{print $2}'|tr "\n" "|"|tr -s " "|tr -d ";,"`

#To get hba model
VAR_HBA_MODEL=`cat $j/inq/*hba.txt|grep  -i  "model"|awk -F: '{print $2}'|tr "\n" "|"|tr -s " "|tr -d ";,"`

#To get hba serial number
#VAR_HBA_SERIAL_NUMBER=`cat $j/inq/*hba.txt|grep  -i  "serial number"|awk -F: '{print $2}'|tr "\n" "|"|tr -s " "|tr -d ";,"`

#To get hba driver
VAR_HBA_DRIVER=`cat $j/inq/*hba.txt|grep  -i  "driver version"|awk -F: '{print $2}'|tr "\n" "|"|tr -s " "|tr -d ","|tr -d ";,"`

#To get fabric name
#VAR_HBA_FABRIC_NAME=`cat $j/hbainfo/hbainfo.txt |grep -i "Fabric name:"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ","|tr -d ";,"`

#To get hba information from hbainfo file
else

#To get hba name
VAR_HBA_NAME=`cat $j/hbainfo/hbainfo.txt|grep  -i -B1 "model description"|grep -iv "model description"|tr -d "-"|tr "\n" "|"|tr -d "*"`

#To ge hba type
VAR_HBA_TYPE=`cat $j/inq/*hba.txt|grep -i "hba type:"|awk -F" " '{print $3,$NF}'|tr '\n' '|'|tr -d ";,"`

#To get model description
VAR_DESCRIPTION=`cat $j/hbainfo/hbainfo.txt |grep  -i  "model description"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ";,"`

#To get firmware version
VAR_FIRMWARE_VERSION=` cat $j/hbainfo/hbainfo.txt |grep  -i  "firmware"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ";,"`

#To get hba model
VAR_HBA_MODEL=`cat $j/hbainfo/hbainfo.txt |grep  "Model:"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ";,"`

#To get serial number
#VAR_HBA_SERIAL_NUMBER=`cat $j/hbainfo/hbainfo.txt |grep  "Serial Number"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ";,"`

#To get hba driver
VAR_HBA_DRIVER=`cat $j/hbainfo/hbainfo.txt |grep  "Driver Version"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ","|tr -d ";,"`

#To get node wwn
VAR_NODE_WWN=`cat $j/hbainfo/hbainfo.txt |grep  "Node Name:"|awk -F: '{print $2}'|tr "\n" "|"`

#To get port wwn
VAR_PORT_WWN=`cat $j/hbainfo/hbainfo.txt |grep -w "Port Name:"|awk -F: '{print $2}'|tr "\n" "|"`

#To get fabric name
#VAR_HBA_FABRIC_NAME=`cat $j/hbainfo/hbainfo.txt |grep -i "Fabric name:"|awk -F: '{print $2}'|tr "\n" "|"|tr -d ","|tr -d ";,"`
fi

#To get multipath version
VAR_MULTIPATH_VERSION=`cat $j/host/rpm_-qa.txt |grep -wi "device-mapper-multipath"|grep -v libs|awk -F"-" '{print $4,$NF}'`
#To get wwn list 
VAR_WWN_LIST=`sed -n '/WWN/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|awk '{print $3}'|sort|uniq|tr '\n' ' '`

#To get array list
VAR_ARRAY_LIST=`sed -n '/Array/,$p' $j/inq/*no_dots_-hds_wwn.txt| sed 1,2d|awk '{print $2}'|sort|uniq|tr '\n' '|'`

#To get disk capacity
VAR_TOTAL_DISK_CAPACITY=0
for i in $VAR_WWN_LIST
do

#To get disk name using wwn
VAR_DISK_NAME=`grep -w $i $j/inq/*no_dots_-hds_wwn.txt|head -1|awk '{print $1}'`

#To ensure disk belongs to open-v
VAR_OPENV_CHECK=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|grep -w OPEN-V`
if [ $? -eq '0' ]
then

#To get disk capacity
VAR_DISK_CAPACITY=`grep -w $VAR_DISK_NAME $j/inq/*no_dots.txt|awk '{print $7}'`

#To get total disk capacity
VAR_TOTAL_DISK_CAPACITY=`expr $VAR_TOTAL_DISK_CAPACITY + $VAR_DISK_CAPACITY`
fi
done
VAR_TOTAL_DISK_CAPACITY=`echo $VAR_TOTAL_DISK_CAPACITY|awk '{$1=$1/1024/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`

#VAR_CHECK_LIST_ARRAY=`echo $VAR_ARRAY_LIST|tr -d '|'`
#if [ ! -z $VAR_CHECK_LIST_ARRAY ]
#then
#To ensure host connected with respective storage array or not
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
#To get finale output data 
echo $VAR_HOSTNAME,$VAR_OSVERSION,$VAR_LUN_LIST,$VAR_ARRAY_LIST,$VAR_STORAGE_ARRAY_LIST,$VAR_ARRAY_STATUS,$VAR_TOTAL_DISK_CAPACITY,$VAR_HBA_NAME,$VAR_HBA_TYPE,$VAR_DESCRIPTION,$VAR_HBA_MODEL,$VAR_FIRMWARE_VERSION,$VAR_HBA_DRIVER,$VAR_NODE_WWN,$VAR_PORT_WWN,$VAR_SPEED,$VAR_MULTIPATH_VERSION >> a.csv
done

echo "HOSTNAME,OS,LUN MAX COUNT,HOST ARRAY LIST,STORAGE ARRAY LIST,ARRAY STATUS,CAPACITY(GB),HBA NAME,HBA TYPE,DESCRIPTION,HBA MODEL,FIRMWARE VAERSION,DRIVER,NODE_WWN,PORT_WWN,SPEED,MPATH VERSION" > output-linux.csv
sort a.csv |uniq >> output-linux.csv
rm -rf a.csv
}


########################
# MAIN
########################

#To ensure array list is present or not
ls|grep *Array-List.csv > /dev/null 2>&1
if [ $? -eq '0' ]
then

#To check logs are compressed or not
ls|grep tar > /dev/null 2>&1
if [ $? -eq '0' ]
then
untar_logs
fi
host_details
else
echo "Please make sure storage array list file is present here..."
fi


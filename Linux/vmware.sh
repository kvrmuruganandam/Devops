#!/bin/bash

######################################################################
# **************************************************                 
# ***       VMware Host Details              	 ***               
# **************************************************                
# Script Name           :       "vmware.sh"
# Author                :       "Muruganandam"                            
# Created Date          :       "2.10.2019"
# Latest Update         :       "9.10.2019"
# Copyright             :       "Copyright 2019, The ZENfra Project" 
# License               :       "VTG"                                
# Version               :       "1.0"                               
# Email                 :       "migrationteam@virtualtechgurus.com"    
# Run Script            :       "./vmware.sh"
#
#
#
# *********************************************
# ***            NOTE                       ***
# *********************************************
# before run script make sure you have only log files and script file in current directory... 
#


###########################
# To get vmware details
###########################

host_details(){


#To collect host list
echo HOST,ESX VERSION > host.csv
sed 1d vmultipath.csv|awk -F "," '{print $1}'|sort|uniq|while read line
do 
  VAR_HOST_OS=`cat vhost.csv|grep -wi "$line"|awk -F "," '{print $2}'|head -1`
echo $line,$VAR_HOST_OS >> host.csv
done

#To collect datastore list
sed 1d vmultipath.csv|awk -F "," '{print $2}'|sort|uniq > a
mv a datastore.csv

#To get emulator type
sed 1d vmultipath.csv|awk -F "," '{print $2","$3}'|sort|uniq > b
mv b model.csv

#To get vm list
while read d_store
do

#To get vm name from vinfo file
grep -iF "[$d_store]" vinfo.csv|awk -F',' '{print $5}'>> sample1.txt

#To get vm name from vdisk file
grep -iF "[$d_store]" vdisk.csv|awk -F',' '{print $1}'>> sample2.txt
done<datastore.csv

#To get uniq VM list
sort sample1.txt|uniq > output
sort sample2.txt|uniq >> output
sort output|uniq > vm_list
rm -rf output sample*


#To create CSV file headings
echo "VMNAME,POWER STATE,CD STATE,PROVISIONED_SIZE(GB),OS,VM_DATASTORE,TYPE,CLUSTER,HOST,ESX_VERSION,HOST HBA MODEL,HOST WWN,ARRAY,DATACENTER,VCENTER" > a.csv

#To get array file
VAR_ARRAY_FILE=`ls|grep -i *Array-List.csv`

#To collect VM details
while read line
do

#To get vCenter name
VAR_VCENTER=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $1}'|head -1`

#To get datacenter name
VAR_DATACENTER=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $2}'|head -1`

#To get cluster name
VAR_CLUSTER=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $3}'|head -1`

#To ge host name
VAR_HOST_NAME=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $4}'|head -1`

#To get hba model
VAR_HOST_HBA_MODEL=`cat vhba.csv|grep -wi "$VAR_HOST_NAME"|awk -F, '{print $4}'|tr '\n' '|'`

#To get host wwn
VAR_HOST_WWN=`cat vhba.csv|grep -wi "$VAR_HOST_NAME"|awk -F, '{print $5}'|tr '\n' '|'`

#To get array name from wwn
for wwn in `echo $VAR_HOST_WWN|tr '|' ' '`
do
grep $wwn $VAR_ARRAY_FILE|awk -F, '{print $1}' >> vm_array
done
VAR_ARRAY_LIST=`cat vm_array|sort|uniq|tr '\n' ' '`
rm -rf vm_array

#To get host os version
VAR_ESX_VERSION=`cat vhost.csv|grep -i "$VAR_HOST_NAME"|awk -F "," '{print $2}'|head -1`

#To get vm name
VAR_VM_NAME=`echo "$line"`

#To get Powerstate
VAR_POWER_STATE=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $9}'|head -1`

#To get cd state
VAR_CD_STATE=`cat vcd.csv|grep -wi "$line"|awk -F "," '{print $2}'|head -1`

#To get vm provisioned size
VAR_VM_PROVISIONED_SIZE=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $6}'|head -1|awk '{$1=$1/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`

#To get vm os
VAR_OS=`cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $7}'|head -1`

#To collect datastore for vm
cat vdisk.csv|grep -wi "$line"|awk -F "," '{print $2}' > vm_datastore
cat vinfo.csv|grep -wi "$line"|awk -F "," '{print $8}' >> vm_datastore
while read list_store
do
echo "$list_store"|cut -d']' -f1|cut -d'[' -f2 >> extra
done<vm_datastore
VAR_VM_DATASTORE=$(sort extra 2> /dev/null|uniq 2> /dev/null |tr '\n' '|' 2> /dev/null )
VAR_VM_DATASTORE_LIST=`echo $VAR_VM_DATASTORE|tr "|" " "`

#To get emulator type
VAR_TYPE_LIST=""
for t in $VAR_VM_DATASTORE_LIST
do
	VAR_TYPE=`grep -wi "$t" model.csv|head -1|awk -F"," '{print $2}'|awk '{$1=$1};1'`
	VAR_TYPE_LIST="$VAR_TYPE_LIST$VAR_TYPE|"
done

#to get final output
echo "$VAR_VM_NAME,$VAR_POWER_STATE,$VAR_CD_STATE,$VAR_VM_PROVISIONED_SIZE,$VAR_OS,$VAR_VM_DATASTORE,$VAR_TYPE_LIST,$VAR_CLUSTER,$VAR_HOST_NAME,$VAR_ESX_VERSION,$VAR_HOST_HBA_MODEL,$VAR_HOST_WWN,$VAR_ARRAY_LIST,$VAR_DATACENTER,$VAR_VCENTER" >> a.csv 
rm -rf vm_datastore extra > /dev/null 2>&1
done<vm_list
sed -e 's/\r//g' a.csv|awk '{$1=$1};1' > vm_data.csv

#To convert csv to xlsx
ssconvert --merge-to=output-vmware.xls vm_data.csv host.csv datastore.csv > /dev/null 2>&1
rm -rf vm_list a.csv vm_data.csv host.csv datastore.csv model.csv
}


########################
# MAIN
########################

#To check array file exist or not
ls|grep *Array-List.csv > /dev/null 2>&1
if [ $? -eq '0' ]
then
host_details
else
echo "Please make sure storage array list file is present here..."
fi

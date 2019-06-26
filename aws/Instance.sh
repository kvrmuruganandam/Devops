#!/bin/bash

#Listing the instances
list_instance(){
T=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[].Value,InstanceId]'|tr '"[],' " "|tr "\t" " ")
echo $T|tr " " "\n"|awk ' {print;} NR % 2 == 0 { print ""; }'| awk ' {print;} NR % 3 == 0 { print "******************"; }'
}

#Create New Instane
create_instance(){
	read -p "Entrer Image Id: " Id
	read -p "Enter Instance Type: " Type
	read -p "Enter Count: " Count
	read -p "Enter KeyName: " key
aws ec2 run-instances --image-id $Id --count $Count --instance-type $Type --key-name $key 

}

#Start Instances
start_instance(){
	
	read -p "Enter Instance Id: " Id
	aws ec2 start-instances --instance-ids $Id
}


#stop Instances
stop_instance(){
	read -p "Enter Instance Id: " Id
	aws ec2 stop-instances --instance-ids $Id
}

#Terminate Instances
terminate_instance(){

	read -p "Enter Instance Id: " Id
	aws ec2 terminate-instances --instance-ids $Id
}

#Main Page
echo "             Welcome To AWS EC2 Management"
echo "             *************************"
echo "1.list_instance"
echo "2.create_instance"
echo "3.start_instance"
echo "4.stop_instance"
echo "5.terminate_instance"
read -p "Choose:" Input
echo "     "
echo "************"

#Options
case "$Input" in
   "1") list_instance 
   ;;
   "2") create_instance 
   ;;
   "3") start_instance 
   ;;

   "4")	stop_instance  
	   ;;
   "5") terminate_instance 
	   ;;
	   
   "6") echo "success"
	   ;; 
esac


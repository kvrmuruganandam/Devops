echo "VM NAME,PROVISIONED SIZE(GB),PATH,CAPACITY(GB),OS,HOST" > output.csv
sed 1d vdisk.csv|awk -F"," '{print $1}'|sort|uniq |while read vm_name
do
VAR_VM=`echo $vm_name`
VAR_PROVISIONED_SIZE=`cat vinfo.csv|grep -wi "$vm_name"|awk -F "," '{print $2}'|head -1|awk '{$1=$1/1024; print $1;}'|awk '{printf "%d\n",$1}'`
VAR_VM_PATH=`grep -wi "$vm_name" vdisk.csv|awk -F"," '{print $3}'|tr '\n' '|'`
VAR_VM_CAPACITY_LIST=`grep -wi "$vm_name" vdisk.csv|awk -F"," '{print $2}'|tr '\n' ' '`
VAR_VM_CAPACITY=""
for disk in $VAR_VM_CAPACITY_LIST
do
VAR_CAP=`echo $disk|awk '{$1=$1/1024; print $1;}'|awk '{printf "%.2f\n",$1}'`
VAR_VM_CAPACITY="$VAR_VM_CAPACITY$VAR_CAP|"
done
VAR_VM_OS=`grep -wi "$vm_name" vdisk.csv|awk -F"," '{print $5}'|head -1`
VAR_HOST=`grep -wi "$vm_name" vdisk.csv|awk -F"," '{print $4}'|head -1`
echo $VAR_VM,$VAR_PROVISIONED_SIZE,$VAR_VM_PATH,$VAR_VM_CAPACITY,$VAR_VM_OS,$VAR_HOST >> output.csv
done

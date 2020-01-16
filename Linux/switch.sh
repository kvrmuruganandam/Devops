rm -rf output-switch.csv > /dev/null 2>&1
sed 1d *zone.csv|sed -e 's/\r//g'|while read line
do
unset VAR_ARRAY
unset VAR_HOST_GROUP
unset VAR_HOST_NAME
unset VAR_WWN
unset VAR_MATCHED_FILE
VAR_ARRAY=`echo $line|awk -F, '{print $1}'` 
VAR_HOST_GROUP=`echo $line|awk -F, '{print $2}'`
VAR_HOST_NAME=`echo $line|awk -F, '{print $3}'`
VAR_WWN=`echo $line|awk -F, '{print $4}'|sed 's/\(..\)/\1:/g;s/:$//'`
VAR_MATCHED_FILE=`grep -irl "$VAR_WWN" --exclude  "a.csv"|tr '\n' ' '`
grep -irl "$VAR_WWN" --exclude  "a.csv" > /dev/null 2>&1
if [ $? -eq '0' ]
then
for file in $VAR_MATCHED_FILE
do
unset VAR_ALIAS
grep -i -B 1 "$VAR_WWN" $file|grep -i "alias" > /dev/null 2>&1
if [ $? -eq '0' ]
then
grep -i "$VAR_WWN" $file|grep -i "alias" > /dev/null 2>&1
if [ $? -eq '0' ]
then
VAR_ALIAS=`grep -i "$VAR_WWN" $file|grep -i "alias"|awk -F: '{print $1}'|awk -F. '{print $2}'|awk '{$1=$1;print}'`
else
VAR_ALIAS=`grep -i -B 1 "$VAR_WWN" $file|grep -i "alias"|head -1|awk -F: '{print $2}'|awk '{$1=$1;print}'`
fi
fi
echo $VAR_ALIAS >> sam
VAR_NUM=`grep -in "$VAR_WWN" $file|grep -v "alias"|awk -F: '{print $1}'|tr '\n' ' '`
for num in $VAR_NUM
do
unset VAR_ZONE
VAR_COUNT=`expr $num - 25`
cat -n $file|grep -w -B 1 "$num"|grep "alias" > /dev/null 2>&1
if [ $? -ne '0' ]
then
VAR_ZONE=`sed -n "$VAR_COUNT,$num p" $file|grep -v "alias"|grep "zone:"|tail -1|awk -F: '{print $2}'|awk '{$1=$1;print}'`
fi
echo $VAR_ZONE >> sample
done
done
VAR_LIST_ALIAS=`cat sam|sort|uniq|tr '\n' '|'`
VAR_LIST_ZONE=`cat sample|sort|uniq|tr '\n' '|'`
rm -rf sample sam
echo "$VAR_ARRAY,$VAR_HOST_GROUP,$VAR_HOST_NAME,$VAR_WWN,$VAR_LIST_ALIAS,$VAR_LIST_ZONE" >> a.csv
else
unset VAR_ALIAS
unset VAR_LIST_ZONE
echo "$VAR_ARRAY,$VAR_HOST_GROUP,$VAR_HOST_NAME,$VAR_WWN,$VAR_ALIAS,$VAR_LIST_ZONE" >> a.csv
fi
done
sed -e 's/\r//g' a.csv > b.csv
echo "ARRAY,HOST GROUP,HOST NAME,WWN,ALIAS NAME,ZONE NAME" > output-switch.csv
cat b.csv|sort|uniq >> output-switch.csv
sed -i '/a\.\csv$/d' output-switch.csv
rm -rf a.csv b.csv

#!/bin/bash

Present_Info=`ifconfig -a|awk '{array[NR]=$0}END{for(i=1;i<NR-8;i=i+9) print array[i],array[i+1]}'|awk -F' ' '{printf "Device: %-8s %-25s %-25s MAC:%-20s\n",$1,$7,$9,$5}'`
Only_DeviceName=`echo  "$Present_Info"|awk -F' ' '{print $2}' `
echo -e "Your Present Information Below:\n$Present_Info\n"
echo -e "Please Make Choice to Change Device:\n"
while true
do
	select Device_Name in $Only_DeviceName;do break;done
	if [ -z $Device_Name ];then continue;
	else	break;
	fi
	done
echo -e "You Want to Change Device $Device_Name"

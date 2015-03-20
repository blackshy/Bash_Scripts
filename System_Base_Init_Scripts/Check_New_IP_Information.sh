#!/bin/bash

IP_ADD_CHECK(){
read -p "Please Enter Your New IP Address Here: " New_IP_Add
while true
do
	IP_Segs=$(echo $New_IP_Add|awk -F'.' '{for(i=1;i<=NF;i++){if($i>=0 && $i<255){print $i}}}'|wc -l)
	if [ $IP_Segs -eq 4 ];then break;
	else echo "Please ReEnter Your New IP Address With Right Schema: [XXX-XXX-XXX-XXX]"
		read -p "Please Enter Your New IP Address Here: " New_IP_Add
	fi
done
}

NETMASK_CHECK(){
read -p "Please Enter Your New NetMask Here: " New_NetMask
while true
do
	Mask_Segs=$(echo $New_NetMask|awk -F'.' '{for(i=1;i<=NF;i++){if($i>=0 && $i<=255){print $i}}}'|wc -l)
	if [ $Mask_Segs -eq 4 ];then break;
	else echo "Please ReEnter Your New NetMask With Right Schema: [XXX-XXX-XXX-XXX]"
		read -p "Please Enter Your New NetMask Here: " New_NetMask
	fi
done
}

#!/bin/bash
#
# Description:
#	Use this scripts can help you to make a new host ready with your own habit;\
#	Set network hostname;\
#	Turn tun off the iptables ip6tables NetworkManager and SElinux!
#
# History:
#	2013/07/08	Michael Sang	0.1.0 #Second release
#	2013/03/06	Clark Cai	0.0.1 #First release

PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/root/bin
export PATH

# Set The Function Text whit Color
SET_COLOR(){
	BOTH_SIDES="echo -en \\033[0;31m"
	HEAD_SIDE="echo -en "###################################################"\n"
	BOTTOM_SIDE="echo -en "###################################################"\n"
	SUBSTANCE="echo -en \\033[0;32m"
	TERMINAL_COLOR="echo -en \\033[0;39m"
	echo ""
	$BOTH_SIDES;$HEAD_SIDE;$SUBSTANCE;echo -en "#    "$1"\n";$BOTH_SIDES;$BOTTOM_SIDE;$TERMINAL_COLOR
	echo ""
}

ERROR_STATUS(){
	exit 1
}

# Gather Net Infomation
GET_NET_INFO(){
	Present_Info=`ifconfig -a|awk '{array[NR]=$0}END{for(i=1;i<NR-8;i=i+9) print array[i],array[i+1]}'|awk -F' ' '{printf "Device: %-8s %-25s %-25s MAC:%-20s\n",$1,$7,$9,$5}'|sed 's/addr:/IP:\ /g'|sed 's/Mask:/NetMask:\ /g'`
        Only_DeviceName=`echo  "$Present_Info"|awk -F' ' '{print $2}' `
        echo -e "Your Present Information Below:\n$Present_Info\n"
        echo -e "Please Make Choice to Change Device:\n"
        while true
        do
        select Device_Name in $Only_DeviceName Nochange;do break;done
        if [ -z "$Device_Name" ];then continue;
        else    break;
        fi
        done
        [ $Device_Name == Nochange ] && exit;
	echo ""
	echo -e "\tYou Want to Change Device $Device_Name"
}

# Check The New IP Format
IP_ADD_CHECK(){
read -p "Please Enter Your New IP Address Here: " New_IP_Add
echo ""
while true
do
	IP_Segs=$(echo $New_IP_Add|awk -F'.' '{for(i=1;i<=NF;i++){if($i>=0 && $i<255){print $i}}}'|wc -l)
	if [ $IP_Segs -eq 4 ];then break;
	else 
		echo ""
		echo "Please ReEnter Your New IP Address With Right Schema: [XXX-XXX-XXX-XXX]"
		echo ""
		read -p "Please Enter Your New IP Address Here: " New_IP_Add
		echo ""
	fi
done
}

# Check The New NetMask Format
NETMASK_CHECK(){
case $1 in
NETMASK)
	echo ""
	read -p "Please Enter Your New NetMask Here: " New_NetMask
	echo ""
	while true
	do
		Mask_Segs=$(echo "$New_NetMask"|awk -F'.' '{for(i=1;i<=NF;i++){if($i>=0 && $i<=255){print $i}}}'|wc -l)
		if [ "$Mask_Segs" -eq 4 ];then break;
		else 
			echo ""
			echo "Please ReEnter Your New NetMask With Right Schema: [XXX.XXX.XXX.XXX]"
			echo ""
			read -p "Please Enter Your New NetMask Here: " New_NetMask
			echo ""
		fi
	done
;;
PREFIX)
	echo ""
	read -p "Please Enter Your New NetMask Here: " New_Prefix
	echo ""
	while true
	do
		Mask_Segs=$(echo "$New_Prefix"|awk -F'.' '{for(i=1;i<=NF;i++){if($i>=0 && $i<=255){print $i}}}'|wc -l)
		if [ "$Mask_Segs" -eq 4 ];then break;
		else 
			echo ""
			echo "Please ReEnter Your New NetMask With Right Schema: [XXX-XXX-XXX-XXX]"
			echo ""
			read -p "Please Enter Your New NetMask Here: " New_Prefix
			echo ""
		fi
	done

;;
esac
}

# Already Has IP Address
ALREADY_HAS_IP(){
Present_IP_Add=$(ifconfig -a|awk '{a[NR]=$0}END{for(i=1;i<NR;i=i+9){print a[i]a[i+1]}}'|grep $Device_Name|grep -w inet|awk -F' ' '{print $7}'|cut -d: -f2)
for Update_Item in $1;
do
	case $Update_Item in
	IPADDR)
	if [ -n "$Present_IP_Add"  ];then
		echo -e "You already have the IP: $Present_IP_Add"
		echo ""
		read -p "Do you want to change it or not [Y/N]:" ChangeOrNot
		while true
		do
		[ -z "$ChangeOrNot" ] && read -p "I am Confusing now,please help me to make a choice here.[Y/N]:" ChangeOrNot
		echo ""
		if [ "$ChangeOrNot" == "N" -o "$ChangeOrNot" == "No" -o "$ChangeOrNot" == "no" -o "$ChangeOrNot" == "nO" -o "$ChangeOrNot" == "n" ];then 
                     	echo -e "Your IP still is: $Present_IP_Add"
			echo ""
			ERROR_STATUS
		fi
		if [ "$ChangeOrNot" == "y" -o "$ChangeOrNot" == "yes" -o "$ChangeOrNot" == "yeS" -o  "$ChangeOrNot" == "yES" -o \
			"$ChangeOrNot" == "yEs" -o "$ChangeOrNot" == "Y" -o "$ChangeOrNot" == "YES" -o "$ChangeOrNot" == "YEs" -o \
			 "$ChangeOrNot" == "Yes" -o "$ChangeOrNot" == "YeS" ];then
			IP_ADD_CHECK
			sed -i '/IPADDR/{s/^IPADDR/\#IPADDR/g}' $Device_Configuration_File && echo "$Update_Item=$New_IP_Add" >> $Device_Configuration_File
                        echo -e "Your IP has changed to: $New_IP_Add"
			break;
		else	
			read -p "Sorry Sir,I don't know what's the $ChangeOrNot mean! Please Rechoice [Y/N]:" ChangeOrNot
		fi
		done
	fi
	;;
	PREFIX)
	NETMASK_CHECK "$Update_Item" && sed -i '/PREFIX/{s/^PREFIX=/\#PREFIX/g}' $Device_Configuration_File && echo "$Update_Item=$New_Prefix" >> $Device_Configuration_File
	;;
	NETMASK)
	NETMASK_CHECK "$Update_Item" && sed -i '/NETMASK/{s/^NETMASK=/\#NETMASK/g}' $Device_Configuration_File && echo "$Update_Item=$New_NetMask" >> $Device_Configuration_File
	;;
	*)
	continue
	;;
	esac
done
}

# Set Net Configuration
SET_NET_CONFIG(){
Device_Configuration_File="/etc/sysconfig/network-scripts/ifcfg-$Device_Name"
[ -f $Device_Configuration_File ] || touch $Device_Configuration_File
[ -n "$(cat /etc/redhat-release|grep 5)" ] && RHEL5="IPADDR NETMASK BOOTPROTO ONBOOT NM_CONTROLLED IPV6INIT" && Net_Config_Change_List=$RHEL5
[ -n "$(cat /etc/redhat-release|grep 6)" ] && RHEL6="IPADDR PREFIX BOOTPROTO ONBOOT NM_CONTROLLED IPV6INIT" && Net_Config_Change_List=$RHEL6
Present_Net_Config_List=$(cat $Device_Configuration_File|egrep "^IPV6INIT|^BOOTPROTO|^ONBOOT|^NM_CONTROLLED|^IPADDR|^PREFIX|^NETMASK")
[ -z "$Present_Net_Config_List" ] && echo -e "You have the $Device_Name Device,but it has no configuration file!"
for Update_Item in $Net_Config_Change_List;do
	Present_Item=$(echo $Present_Net_Config_List|grep $Update_Item)
	case $Update_Item in
	IPV6INIT)
	[ -z "$Present_Item" ] && echo "$Update_Item=no" >> $Device_Configuration_File
	sed -i '/IPV6INIT/{s/yes/no/g}' $Device_Configuration_File
	;;
	BOOTPROTO)
	[ -z "$Present_Item" ] && echo "$Update_Item=static" >> $Device_Configuration_File
	sed -i '/BOOTPROTO/{s/dhcp/static/g}' $Device_Configuration_File
	;;
	ONBOOT)
	[ -z "$Present_Item" ] && echo "$Update_Item=yes" >> $Device_Configuration_File
	sed -i '/ONBOOT/{s/no/yes/g}' $Device_Configuration_File
	;;
	NM_CONTROLLED)
	[ -z "$Present_Item" ] && echo "$Update_Item=no" >> $Device_Configuration_File
	sed -i '/NM_CONTROLLED/{s/yes/no/g}' $Device_Configuration_File
	;;
	IPADDR)
	[ -z "$Present_Item" ] && IP_ADD_CHECK && echo "$Update_Item=$New_IP_Add" >> $Device_Configuration_File && echo "" && echo -e "Your New IP Address:\t\t $New_IP_Add" && echo ""
	[ -n "$Present_Item" ] && ALREADY_HAS_IP "$Update_Item"
	;;
	PREFIX)
	[ -z "$Present_Item" ] && NETMASK_CHECK ""$Update_Item"" && echo "$Update_Item=$New_Prefix" >> $Device_Configuration_File && echo "" && echo -e "Your New NetMask:\t\t "$New_Prefix"" && echo ""
	[ -n "$Present_Item" ] && ALREADY_HAS_IP "$Update_Item"
	;;
	NETMASK)
	[ -z "$Present_Item" ] && NETMASK_CHECK ""$Update_Item"" && echo "$Update_Item=$New_NetMask" >> $Device_Configuration_File && echo "" && echo -e "Your New NetMask:\t\t $New_NetMask" && echo ""
	[ -n "$Present_Item" ] && ALREADY_HAS_IP "$Update_Item"
	;;
	*)
	continue
	;;
	esac
done
	echo ""
	echo -e "Restarting the $Device_Name device Link..."
	/sbin/ifdown $Device_Name >/dev/null 2>&1
	/sbin/ifup $Device_Name >/dev/null 2>&1
	echo ""
}

# Turn Off The Unnecessary Services
TURNOFF_SERVICES(){
for service in NetworkManager iptables ip6tables;
do 
	service $service stop > /dev/null 2>&1
	chkconfig $service off > /dev/null 2>&1
	echo -e "The\t$service\tis stoped! If you want to start\t$service\tService. Use this command: service\t$service\tstart"
done
}

# Disable SeLinux
DISABLE_SELINUX(){
SELINUX_CONFIG=/etc/selinux/config
sed -i '/SELINUX/{s/enforcing/disabled/g}' $SELINUX_CONFIG
setenforce 0
echo ""
echo -e "If you want to change it, Please do that in "\"$SELINUX_CONFIG\"" by yourself!"
}

# Set Hostname
SET_HOSTNAME(){
HOSTNAME_CONFIG=/etc/sysconfig/network
echo -e "Your present hostname is "$HOSTNAME""
echo ""
read -p "Do you want to change it [Y/N]: " ChangeOrNot
while true 
do
	if [ "$ChangeOrNot" == "N" -o "$ChangeOrNot" == "No" -o "$ChangeOrNot" == "no" -o "$ChangeOrNot" == "nO" -o "$ChangeOrNot" == "n" ];then 
		echo ""
		echo -e "Your hostname still is: $HOSTNAME"
		break;
	fi
	if [ "$ChangeOrNot" == "y" -o "$ChangeOrNot" == "yes" -o "$ChangeOrNot" == "yeS" -o "$ChangeOrNot" == "yES" -o "$ChangeOrNot" == "yEs" \
		 -o "$ChangeOrNot" == "Y" -o "$ChangeOrNot" == "YES" -o "$ChangeOrNot" == "YEs" -o "$ChangeOrNot" == "Yes" -o "$ChangeOrNot" == "YeS" ];then
		echo ""
		read -p "Please input your New Hostname here:" New_HostName
		sed -i "/HOSTNAME/{s/localhost.localdomain/$New_HostName/g}" $HOSTNAME_CONFIG
		/bin/hostname $New_HostName
		echo ""
		echo -e "The hostname is change to '$New_HostName'"
		break;
	else 
		echo ""
		echo -e   "I don't know what your choice is !"
		echo ""
		read -p "Please Rechoice:" ChangeOrNot
	fi
done 
}

SET_COLOR " Turn Off The Unnecessary Services"
TURNOFF_SERVICES
SET_COLOR " Disable SeLinux"
DISABLE_SELINUX
SET_COLOR " Set Hostname"
SET_HOSTNAME
SET_COLOR " Gather Net Infomation"
GET_NET_INFO
SET_COLOR " Set Net Configuration"
SET_NET_CONFIG

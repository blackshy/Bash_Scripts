#!/bin/bash
#Program:
#	Use this scripts can help you to make a new host ready with your own habit;
#	Like set 'network' 'hostname' tun off the 'iptables' 'NetworkManager' and 'SElinux'!
#History:
#	2013/03/06	Clark	First release
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/root/bin
export PATH

# Set The Function Text whit Color
SET_COLOR(){
	BOTH_SIDES="echo -en \\033[0;31m"
	LEFT_SIDE="echo -en "###############""
	RIGHT_SIDE="echo -en "###############"\n"
	SUBSTANCE="echo -en \\033[0;32m"
	TERMINAL_COLOR="echo -en \\033[0;39m"
	$BOTH_SIDES;$LEFT_SIDE;$SUBSTANCE;echo -en "<< "$1" >>";$BOTH_SIDES;$RIGHT_SIDE;$TERMINAL_COLOR
}

# Gather Net Infomation
GET_NET_INFO(){
        Present_Info=`ifconfig -a|awk '{array[NR]=$0}END{for(i=1;i<NR-8;i=i+9) print array[i],array[i+1]}'|awk -F' ' '{printf "Device: %-8s %-25s %-25s MAC:%-20s\n",$1,$7,$9,$5}'`
        Only_DeviceName=`echo  "$Present_Info"|awk -F' ' '{print $2}' `
        echo -e "Your Present Information Below:\n$Present_Info\n"
        echo -e "Please Make Choice to Change Device:\n"
        while true
        do
        select Device_Name in $Only_DeviceName;do break;done
        if [ -z $Device_Name ];then continue;
        else    break;
        fi
        done
        echo -e "You Want to Change Device $Device_Name"
}

# Check The New IP Format
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

# Check The New NetMask Format
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

# Already Has IP Address
ALREADY_HAS_IP(){
Persent_IP_ADD=$(cat $Device_Configuration_File|egrep "^IPADDR|^PREFIX|^NETMASK")
for Update_Item in IPADDR PREFIX NETMASK;
do
	Present_Item=$(echo $Persent_IP_ADD|grep $Update_Item)
	case $Update_Item in
	IPADDR)
	if [ !-z $Persent_Item  ];then
		echo -e "You already have the IP: $Present_Item"
		read -p "Do you want to change it or not [Y/N]:" ChangeOrNot
		while true
		do
		[ -z $ChangeOrNot ] &&  read -p "I am Confusing now,please help me to make a choice here.[Y/N]:" ChangeOrNot
		if [ "$ChangeOrNot" == "y" -o "$ChangeOrNot" == "yes" -o "$ChangeOrNot" == "yeS" -o  "$ChangeOrNot" == "yES" -o \
			"$ChangeOrNot" == "yEs" -o "$ChangeOrNot" == "Y" -o "$ChangeOrNot" == "YES" -o "$ChangeOrNot" == "YEs" -o \
			 "$ChangeOrNot" == "Yes" -o "$ChangeOrNot" == "YeS" ];then
			sed -i '/IPADDR/{s/^IPADDR/\#IPADDR/g}' $Device_Configuration_File && echo $Update_Item=$New_IP_ADD >> $Device_Configuration_File
                        echo -e "Your IP has changed to $Update_Item=$New_IP_ADD"
		elif [ "$ChangeOrNot" == "N" -o "$ChangeOrNot" == "No" -o "$ChangeOrNot" == "no" -o "$ChangeOrNot" == "nO" -o "$ChangeOrNot" == "n" ];then 
                     	echo -e "Your IP still is:$Persent_Item"
		else read -p "Sorry Sir,I don't know what\' the $ChangeOrNot mean!\nPlease Rechoice [Y/N]:" ChangeOrNot
		fi
		done
	fi
	;;
	PREFIX)
	[ !-z $Persent_Item ] && sed -i '/PREFIX/{s/^PREFIX=/\#PREFIX/g}' $Device_Configuration_File && echo "$Persent_Item=$New_Prefix" >> $Device_Configuration_File
	echo "$Persent_Item=$New_Prefix" >> $Device_Configuration_File
	;;
	NETMASK)
	[ !-z $Persent_Item ] && sed -i '/NETMASK/{s/^NETMASK=/\#NETMASK/g}' $Device_Configuration_File && echo "$Persent_Item=$New_NetMask" >> $Device_Configuration_File
	echo "$Persent_Item=$New_NetMask" >> $Device_Configuration_File
	;;
	*)
	continue
	;;
	esac
done
}

# Set Net Configuration
SET_NET_CONFIG(){
Device_Configuration_File=/etc/sysconfig/network-scripts/ifcfg-$Device_Name
[ -f $Device_Configuration_File ] || touch $Device_Configuration_File
Net_Config_Change_List="IPADDR BOOTPROTO ONBOOT NM_CONTROLLED PREFIX NETMASK"
Persent_Net_Config_List=$(cat ifcfg-$Device_Name|egrep "^BOOTPROTO|^ONBOOT|^NM_CONTROLLED|^IPADDR|^PREFIX|^NETMASK")
[ -z $Persent_Net_Config__List ] && echo -e "You have the $Device_Name Device,but it has no configuration file!"
IP_ADD_CHECK
NETMASK_CHECK
for Update_Item in $Net_Config_Change_List;do
	Persent_Item=$(echo Present_Net_Config_List|grep $Update_Item)
	case $Update_Item in
	BOOTPROTO)
	[ !-z $Persent_Item ] && sed -i '/BOOTPROTO/{s/dhcp/static/g}' $Device_Configuration_File
	echo "$Persent_Item=static" >> $Device_Configuration_File
	;;
	ONBOOT)
	[ !-z $Persent_Item ] && sed -i '/ONBOOT/{s/no/yes/g}' $Device_Configuration_File
	echo "$Persent_Item=yes" >> $Device_Configuration_File
	;;
	NM_CONTROLLED)
	[ !-z $Persent_Item ] && sed -i '/NM_CONTROLLED/{s/yes/no/g}' $Device_Configuration_File
	echo "$Persent_Item=no" >> $Device_Configuration_File
	;;
	IPADDR)
	[ !-z $Persent_Item ] && ALREADY_HAS_IP
 	echo "$Persent_Item=$New_IP_Add" >> $Device_Configuration_File
	echo -e "Your New IP Address:\t\t $New_IP_Add"	
	fi
	;;
	PREFIX)
	[ !-z $Persent_Item ] && ALREADY_HAS_IP
	echo "$Persent_Item=$New_Prefix" >> $Device_Configuration_File
	echo -e "Your New NetMask:\t\t $New_Prefix"
	;;
	NETMASK)
	[ !-z $Persent_Item ] && ALREADY_HAS_IP
	echo "$Persent_Item=$New_NetMask" >> $Device_Configuration_File
	echo -e "Your New NetMask:\t\t $New_NetMask"
	;;
	*)
	continue
	;;
	esac
done
	echo -e "Restarting the $Device_Name device Link..."
	/sbin/ifdown $Device_Name >/dev/null 2>&1
	/sbin/ifup $Device_Name >/dev/null 2>&1
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
echo -e "The SElinux is disabled!\nIf you want to change it, Please do that in "\"$SELINUX_CONFIG\"" by yourself!"
}

# Set Hostname
SET_HOSTNAME(){
HOSTNAME_CONFIG=/etc/sysconfig/network
echo -e "Your present hostname is "$HOSTNAME""
read -p "Do you want to change it [Y/N]: " ChangeOrNot
while true 
do
	if [ "$ChangeOrNot" == "y" -o "$ChangeOrNot" == "yes" -o "$ChangeOrNot" == "yeS" -o "$ChangeOrNot" == "yES" -o "$ChangeOrNot" == "yEs" \
		 -o "$ChangeOrNot" == "Y" -o "$ChangeOrNot" == "YES" -o "$ChangeOrNot" == "YEs" -o "$ChangeOrNot" == "Yes" -o "$ChangeOrNot" == "YeS" ];then
		read -p "Please input your New Hostname here:" New_HostName
		sed -i "/HOSTNAME/{s/localhost.localdomain/$New_HostName/g}" $HOSTNAME_CONFIG
		/bin/hostname $New_HostName
		echo -e "The hostname is change to '$New_HostName'"
		break;
	elif [ "$ChangeOrNot" == "N" -o "$ChangeOrNot" == "No" -o "$ChangeOrNot" == "no" -o "$ChangeOrNot" == "nO" -o "$ChangeOrNot" == "n" ];then 
		echo -e "Your hostname still is: $HOSTNAME"
		break;
	else 
		echo -e   "I don't know what your choice is !"
		read -p "Please use 'y' or 'n' to make your choice:" ChangeOrNot
	fi
done 
}

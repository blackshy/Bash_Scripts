#!/bin/bash

Device_Configuration_File=/etc/sysconfig/network-scripts/ifcfg-$Device_Name
[ -f $Device_Configuration_File ] || touch $Device_Configuration_File
Net_Config_Change_List="BOOTPROTO ONBOOT NM_CONTROLLED IPADDR PREFIX NETMASK"
Persent_Net_Config_List=$(cat ifcfg-$Device_Name|egrep "^BOOTPROTO|^ONBOOT|^NM_CONTROLLED|^IPADDR|^PREFIX|^NETMASK")
[ -z $Persent_Net_Config__List ] && echo -e "You have the $Device_Name Device,but it has no configuration file!"
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

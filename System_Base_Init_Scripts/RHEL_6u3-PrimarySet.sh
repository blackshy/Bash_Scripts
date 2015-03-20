#!/bin/bash
#Program:
#	Use this scripts can help me to make a new host ready in my habit;
#	Like set 'network' 'hostname' tun off the 'iptables' 'NetworkManager'and 'SElinux'!
#History:
#	2013/03/06	Clark	First release
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/root/bin
export PATH
#################################<Turnoff The Service >#####################################
echo -e "############## << Turnoff The Service >> ##############\n"
for service in NetworkManager iptables 
do 
	if [ $service = NetworkManager ];then
		sta=`service $service status |grep running`
		if [ "$sta" != "" ];then
			service $service stop 
			chkconfig $service off
		fi
	elif [ $service = iptables ];then
		sta=`service $service status |grep 'not running'`
		if [ "$sta" != "" ];then
			service $service stop
			chkconfig $service off
		fi
	fi
   echo -e "The $service is stop!\nIf you want to start $service 	USE : 'service $service start'"
done
echo -e "\n"
#################################<Disabled SELINUX>########################################
echo -e "############## << Disabled SElinux >> #################\n"
selinux=/etc/selinux/config
cat $selinux |grep '^SELINUX='| sed -i 's/enforcing/disabled/g' $selinux
echo -e "The SElinux is disabled!\nIf you want to change it , Please do that in  '$selinux'  by yourself\n"
#################################<Set Hostname>########################################
echo -e "################# << Set Hostname >> ##################\n"
echo -e "Your hostname is "$HOSTNAME""
read -p "Do you want to change it [Y/N]: " choi
while true 
do
if [ "$choi" == "" ];then
	read  -p  "You make the Default choice:" choi
	choi="$choi";
elif [ "$choi" == "y" -o "$choi" == "Y" ];then
	read -p "Please input your NEW Hostname:" host
	cat /etc/sysconfig/network |grep HOST |sed -i "s/localhost.localdomain/$host/g" /etc/sysconfig/network
	hostname $host
	echo -e "The hostname is change to '$host'"
	break;
elif [ "$choi" == "N" -o "$choi" == "n" ];then 
	echo -e "Your hostname still is : $HOSTNAME"
	break;
else 
	echo -e   "I don't know what your choice is !"
	read -p "Please use 'y' or 'n' to make choice:" choi
	choi=$choi;
fi
done 
echo -e "\n"
################################<Set Network>##############################################
echo -e "################# << Set Network >> ###################\n"
test=`ls -l  /etc/sysconfig/network-scripts/|grep ifcfg|sed 's/^.*-//g'`
echo -e "<<DEVICE LIST>>\n$test\n"
read -p "Please choice a NET-DEVICE name from list:" DEV
TEST=`echo $test |grep $DEV`
while [ "$TEST" == "" ]
do 
	echo -e "The divice you pick does not exsit!"
	read -p "Please input a DEVICE name from list:" DEV
	echo -e "<<DEVICE LIST>>\n$test\n"
	DEV=$DEV
	TEST=`echo $test |grep $DEV`
done 
device="/etc/sysconfig/network-scripts/ifcfg-$DEV"
PROTO=`cat $device |grep 'BOOTPROTO="dhcp"'`
NM=`cat $device |grep 'NM_CONTROLLED="yes"'`
BOOT=`cat $device |grep 'ONBOOT="no"'`
IPADDR=`cat $device |grep '^IPADDR'`

[ "$PROTO" != "" ] && echo $PROTO | sed -i 's/="dhcp"/="none"/g' $device
[ "$NM" != "" ] && echo $NM | sed -i 's/ED="yes"/ED="no"/g' $device
[ "$BOOT" != "" ] && echo $BOOT | sed -i 's/OT="no"/OT="yes"/g' $device
if [ "$IPADDR" != "" ];then
	echo -e "You already have the IP: $IPADDR"
	read -p "Do you want to change it or not [Y/N]:" choice
	while [ $choice = $choice ] 
	do
		while [ "$choice" == "" ]
			do read -p "You have to make choice [Y/N]:" choice 
			choice=$choice
			done
		if [ "$choice" == "y" -o "$choice" == "Y" ];then
			read -p "Please input an IP ADDRESS for your host:"  IP
			while true 
			do
                   		ip=`echo $IP |grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|grep '\.'`
                   		if [ "$ip" == "" ];then
                                        echo -e "You input a wrong IP ADDRESS!"
                                        read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                   		elif [ "$ip" != "" ];then
                        		ip1=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f1|sed 's/^0*/0/g'`
						if [ "$ip1" != "0" ];then
                                	        	 ip1=`echo $ip1|sed 's/^0*//g'`
                                		fi
                        		ip2=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f2|sed 's/^0*/0/g'`
						if [ "$ip2" != "0" ];then
                                	        	 ip2=`echo $ip2|sed 's/^0*//g'`
                                		fi
                        		ip3=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f3|sed 's/^0*/0/g'`
						if [ "$ip3" != "0" ];then
                                	        	 ip3=`echo $ip3|sed 's/^0*//g'`
                                		fi
                        		ip4=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f4|sed 's/^0*/0/g'`
						if [ "$ip4" != "0" ];then
                                	        	 ip4=`echo $ip4|sed 's/^0*//g'`
                                		fi
                               		if [ "$ip1" == "" ] || [ "$ip1" -lt "0" -o "$ip1" -gt "255" ];then
                                        	echo -e "You input a wrong IP ADDRESS!"
                                        	read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                                	elif [ "$ip2" == "" ] || [ "$ip2" -lt "0" -o "$ip2" -gt "255" ];then
                                        	echo -e "You input a wrong IP ADDRESS!"
                                        	read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                                	elif [ "$ip3" == "" ] || [ "$ip3" -lt "0" -o "$ip3" -gt "255" ];then
                                       		echo -e "You input a wrong IP ADDRESS!"
                                        	read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                                	elif [ "$ip4" == "" ] || [ "$ip4" -lt "0" -o "$ip4" -gt "255" ];then
                                        	echo -e "You input a wrong IP ADDRESS!"
                                        	read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                                	else    IP="$ip1.$ip2.$ip3.$ip4"
                                        	break
                        	        fi
				fi
			done
			echo $IPADDR |sed -i 's/^IPADDR/\#IPADDR/g' $device
			echo IPADDR=$IP >> $device
                        echo -e "Your IP is change to IPADDR=$IP"
			cat $device |grep 'PREFIX='|sed -i 's/PREFIX=/\#PREFIX/g' $device
			echo 'PREFIX=24' >> $device
			echo -e "Your default 'NETMASK' is '255.255.255.0' "
			service network restart
			exit 0	
		elif [ "$choice" == "n" -o "$choice" == "N" ];then
                     	echo -e "Your IP sill is:$IPADDR"
			echo -e "Your default 'NETMASK' is '255.255.255.0'\n << Tips >>\nIf your NETMASK is not 255.255.255.0\nPlease change it in '$device' by yourself!\n  "
			service network restart
			exit 0	
		else read -p "I don't know what your choice is\nPlease choice again [Y/N]:" choice
                                choice=$choice
		fi
	done

else
	read -p "Please input an IP ADDRESS for your host:"  IP
	while true 
		do
                   ip=`echo $IP |grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|grep '\.'`
                	if [ "$ip" == "" ];then
				echo -e "You input a wrong IP ADDRESS!"
				read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                   	elif [ "$ip" != "" ];then
                        	ip1=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f1|sed 's/^0*/0/g'`
					if [ "$ip1" != "0" ];then
                                	         ip1=`echo $ip1|sed 's/^0*//g'`
                                	fi
                        	ip2=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f2|sed 's/^0*/0/g'`
					if [ "$ip2" != "0" ];then
                                	         ip2=`echo $ip2|sed 's/^0*//g'`
                                	fi
                       		ip3=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f3|sed 's/^0*/0/g'`
					if [ "$ip3" != "0" ];then
                                	         ip3=`echo $ip3|sed 's/^0*//g'`
                                	fi
                        	ip4=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|cut -d '.' -f4|sed 's/^0*/0/g'`
					if [ "$ip4" != "0" ];then
                                	         ip4=`echo $ip4|sed 's/^0*//g'`
                                	fi
                             if [ "$ip1" == "" ] || [ "$ip1" -lt "0" -o "$ip1" -gt "255" ];then
                                	echo -e "You input a wrong IP ADDRESS!"
                                        read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                             elif [ "$ip2" == "" ] || [ "$ip2" -lt "0" -o "$ip2" -gt "255" ];then
                                        echo -e "You input a wrong IP ADDRESS!"
                                        read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                             elif [ "$ip3" == "" ] || [ "$ip3" -lt "0" -o "$ip3" -gt "255" ];then
                                        echo -e "You input a wrong IP ADDRESS!"
                                        read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                             elif [ "$ip4" == "" ] || [ "$ip4" -lt "0" -o "$ip4" -gt "255" ];then
                                        echo -e "You input a wrong IP ADDRESS!"
                                        read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
                             else    IP="$ip1.$ip2.$ip3.$ip4"
                                        break
                             fi
                	fi
		done
 	echo "IPADDR=$IP" >> $device
	echo -e "Your host IPADDR=$IP"	
	cat $device |grep 'PREFIX='|sed -i 's/PREFIX=/\#PREFIX/g' $device
	echo 'PREFIX=24' >> $device
	echo -e "Your default 'NETMASK' is '255.255.255.0'\n << Tips >>\nIf your NETMASK is not 255.255.255.0\nPlease change it in '$device' by yourself!\n "
	service network restart
	exit 0	
fi
	
###############################<<DONE>>##################################################

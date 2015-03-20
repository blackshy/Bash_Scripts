#!/bin/bash
#Program:
#        To set an ip adress for a net-device and make sure you inputs is right for IPv4 rules!  
#      
#History:
#       2013/03/09      Clark   First release
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/root/bin
export PATH

read -p "Please input an IP ADDRESS for your host:"  IP
while true 
do
                   ip=`echo $IP |grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|grep '\.'`
                   if [ "$ip" == "" ];then
                                        echo -e "You input a wrong IP ADDRESS!"
                                        read -p "Please retype an IP ADDRESS like [xxx.xxx.xxx.xxx] :" IP
		   elif [ "$ip" != "" ];then

			ip1=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|cut -d '.' -f1|sed 's/^0*/0/g'`
				if [ "$ip1" != "0" ];then
					 ip1=`echo $ip1|sed 's/^0*//g'`
				fi
			ip2=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|cut -d '.' -f2|sed 's/^0*/0/g'`
				if [ "$ip2" != "0" ];then
				 ip2=`echo $ip2|sed 's/^0*//g'`
				fi
			ip3=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|cut -d '.' -f3|sed 's/^0*/0/g'`
				if [ "$ip3" != "0" ];then
				 ip3=`echo $ip3|sed 's/^0*//g'`
				fi
			ip4=`echo $ip|grep -v '[a-z]'|grep -v '[A-Z]'|grep -v ','|cut -d '.' -f4|sed 's/^0*/0/g'`
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
echo $IP


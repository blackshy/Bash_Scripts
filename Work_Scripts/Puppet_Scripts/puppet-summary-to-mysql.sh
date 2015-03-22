#!/bin/bash

Report_Dir="/data0/puppet-reports"
Puppet_Clients_List="/usr/bin/puppet cert list -all"
Report_Time="$(date +"%Y-%m-%d")"
Report_Conn="mysql -umon_report -pmon_report -h 192.168.0.100 -D mon_report"
Puppet_Clients_Signed_List="$($Puppet_Clients_List|grep '+' |awk -F'"' '{print $2}'|grep -v "puppet.gomeo2o.cn"|tr "\n\r" " ")"
Puppet_Clients_Unsigned_List="$($Puppet_Clients_List|grep -v '+' |awk -F'"' '{print $2}'|tr "\n\r" " ")"
if [ ! -z "${Puppet_Clients_Unsigned_List}" ];then
	for Client_Unsigned in ${Puppet_Clients_Unsigned_List};
	do
		Status='4'
		Description="已请求证书签名，尚未通过！"
		${Report_Conn} -e "insert rep_puppet(ip,disabled_status,description,reportdate) values('${Client_Unsigned}','${Status}','${Description}','${Report_Time}');"
	done
fi
for Client_Signed in ${Puppet_Clients_Signed_List};
do
	Status='0'
	Description="Status OK!"
	if [ -d "$Report_Dir/$Client_Signed" ];then
		Result=$(find $Report_Dir/$Client_Signed -cmin -20 -type f -exec ls {} \;)
		cd "$Report_Dir/$Client_Signed"
		if [ ! -z "$Result" ];then
			Last_Log=$(echo -e "$Result"|tail -n 1)
			Exec_Status=$(cat "$Last_Log"|grep "^\ \ status"|awk '{print $2}')
			if [ "$Exec_Status" == "failed" ];then
				Status='1'
				Description="执行资源失败！"
			fi
		else
			Last_Log=$(ls -1 | tail -n 1)
			Last_Time=$(stat $Last_Log |grep Change|cut -d. -f1|awk '{print $2" "$3}')
			Status='2'
			Description="$(echo -e "最后同步时间： $Last_Time")"
		fi
	
	else
		Status='3'
		Description="未安装puppet客户端！"
	fi
	if [ ${Status} != '0' ];then
		${Report_Conn} -e "insert rep_puppet(ip,disabled_status,description,reportdate) values('${Client_Signed}','${Status}','${Description}','${Report_Time}');"
	fi
done

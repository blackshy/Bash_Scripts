#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

ERR_FUN(){
	echo -e "\n\tSorry Sir, We got problems here, please handle it!\n"
	exit 1;
}

#Check The User ID
Check_ID(){
	if [ $(id -u) != "0" ]; then
		printf "Error: You must be root to run this script!\n"
		ERR_FUN;
	fi
}


#Here to display some information about this script!



echo -e "Your Server Operate System Release and Version is:";
echo -e "\t$(cat /etc/redhat-release)\n";
echo -e "Your Yum Server Repo List Here:";
echo -e "$(yum repolist 2> /dev/null |awk '{a[NR]=$0}END{for(i=4;i<NR;i++)print a[i]}'|awk -F' ' '{print "\t"$1}')\n"

yum install -y nginx php-fpm php-mysql mysql-server mysql php-eaccelerator php-gd php-mcrypt php-pdo php-cli php-common libmcrypt 2> /dev/null |grep "No package"
if [ $? != 0 ]
	then echo -e "Sir! All rpm packages for LNMP server has been installed successfully!\n"
else
	     echo -e "Sorry Sir! We have to Troubleshooting the rpm packages installing ERRORS!\n"
	     ERR_FUN;
fi

#Setting The Nginx Service Configuration File!

if [ -f conf.d/nginx.conf  -a  -d /etc/nginx/nginx.conf ];then
	/bin/cp -fv conf.d/nginx.conf /etc/nginx/nginx.conf
else
	echo -e "Sorry Sir! We Lost the Nginx service configuration files, Please Check it out!"
fi

service nginx start

#Setting The PHP Service Configuration File!
if [ -f conf.d/php.ini  -a  -d /etc/php.ini ];then
	/bin/cp -fv conf.d/php.ini /etc/php.ini
else
	echo -e "Sorry Sir! We Lost the PHP configuration files, Please Check it out!"
fi

if [ -f conf.d/www.conf  -a  -f /etc/php-fpm.d/www.conf ];then
	/bin/cp -fv conf.d/www.conf /etc/php-fpm.d/www.conf
else
	echo -e "Sorry Sir! We Lost the PHP-FPM service configuration files, Please Check it out!"
fi

service php-fpm start



#Setting The Mysql Services Security!
service mysqld start
/usr/bin/mysqladmin -u root password solutionware

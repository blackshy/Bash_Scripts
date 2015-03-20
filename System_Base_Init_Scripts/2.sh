#!/bin/bash  -x
#Program:
#	Use this scripts can help you to make a new host ready with your own habit;
#	Like set 'network' 'hostname' tun off the 'iptables' 'NetworkManager' and 'SElinux'!
#History:
#	2013/03/06	Clark	First release
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/root/bin
export PATH

. ./1.sh
# Set The Function Text whit Color
SET_COLOR
# Turn Off The Unnecessary Services
TURNOFF_SERVICES
# Disable SeLinux
DISABLE_SELINUX
# Set Hostname
SET_HOSTNAME
# Gather Net Infomation
GET_NET_INFO
# Set Net Configuration
SET_NET_CONFIG
# Check The New IP Format
IP_ADD_CHECK
# Check The New NetMask Format
NETMASK_CHECK

#!/bin/bash

read -p "here:" var

if [ $var == "y|Y|ye|yE" ];then echo $var;
else echo No
fi

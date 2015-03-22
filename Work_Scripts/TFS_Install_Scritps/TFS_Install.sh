#!/bin/bash

rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install libuuid-devel zlib-devel mysql-devel  automake autoconfig cmake libtool  gcc-c++  readline-devel  readline   ncurses-devel ncurses keepalived
chkconfig keepalived on

tar zxvf pcre-8.33.tar.gz
tar zxvf tb-common-utils.tar.gz
tar jxvf jemalloc-3.6.0.tar.bz2
tar zxvf tengine-2.0.2.tar.gz
tar zxvf lloyd-yajl-2.1.0-0-ga0ecdde.tar.gz

cd jemalloc-3.6.0
./configure && make && make install
cd ..

cd lloyd-yajl-66cb08c/
./configure && make && make install
cd ..


echo "export TBLIB_ROOT=/usr/local/tb-common-utils" >> /root/.bash_profile
source /root/.bash_profile

cd tb-common-utils
sh build.sh
cd ..



cd release-2.2.16/
sh build.sh init
./configure --prefix=/usr/local/tfs  --with-release  --without-tcmalloc
sed -i '20s/^$/#include\ <stdint.h>/g' src/common/session_util.h
sed -i '1584s/strstr/(char\ *)strstr/g' src/name_meta_server/meta_server_service.cpp
make && make install
cp conf/ds.conf conf/ns.conf conf/rs.conf conf/rc.conf conf/meta.conf /usr/local/tfs/conf/
cd ..

cp /usr/local/lib/* /lib64
/usr/local/tfs/scripts/stfs format 1

cd tengine-2.0.2
./configure --prefix=/usr/local/tengine  --add-module=../nginx-tfs/trunk --with-pcre=../pcre-8.33
make && make install
cd ..

#!/bin/bash

. ./jindutiao.sh
echo -e "\n Copying Files...  \c"
rotate &
ROTATE_PID=$!
#cp -afr /etc /tmp >/dev/null 2>&1
sleep 1
kill -19 $ROTATE_PID >/dev/null 2>&1
echo "OVER!"


echo -e "\n Doing Tar Commond...  \c"
rotate &
ROTATE_PID=$!
#tar zcvf /tmp/etc.tar.gz /etc >/dev/null 2>&1
sleep 2
kill -19 $ROTATE_PID >/dev/null 2>&1
echo "OVER!"

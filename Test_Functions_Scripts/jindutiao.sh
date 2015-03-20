#!/bin/bash
rotate(){
SPEED=0.03
COUNT="0"
stty -echo >/dev/null 2>&1
while :
do
	COUNT=`expr $COUNT + 1`
	case $COUNT in
	"1") echo -e '-\\'"\b\b\c"   
	sleep $SPEED
	;;
	"2") echo -e '\\|'"\b\b\c"
	sleep $SPEED
	;;
	"3") echo -e "|/\b\b\c"
	sleep $SPEED
	;;
	"4") echo -e '/-'"\b\b\c"
	sleep $SPEED
	;;
	*) COUNT="0"
	;;
	esac
done
stty echo
}

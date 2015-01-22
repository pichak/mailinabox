#!/bin/bash

PROCESS=postgrey

/etc/init.d/$PROCESS start
if [ "$?" -eq "0" ]; then

while [ `ps aux | grep $PROCESS | grep -v grep | wc -l` -gt 0 ]; do
	sleep 30
done

fi

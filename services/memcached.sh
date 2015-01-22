#!/bin/bash

PROCESS=memcached

/etc/init.d/$PROCESS start
if [ "$?" -eq "0" ]; then

while [ `ps -C $PROCESS -o pid= | wc -l` -gt 0 ]; do
	sleep 60
done

fi

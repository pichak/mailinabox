#!/bin/bash

PROCESS=fail2ban

/etc/init.d/$PROCESS start
if [ "$?" -eq "0" ]; then

while [ `ps aux | grep fail2ban | grep -v grep  | wc -l` -gt 0 ]; do
	sleep 30
done

fi

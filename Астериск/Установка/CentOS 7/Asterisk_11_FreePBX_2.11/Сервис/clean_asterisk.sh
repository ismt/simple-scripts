#!/bin/bash

max_days=50
monitor_dir=/var/spool/asterisk/monitor

find $monitor_dir -path '*.wav' -type f -mtime +$max_days -delete -print
find $monitor_dir -type d -empty -delete -print

mysql_root_password=ZpC
mysql -v -uroot -p$mysql_root_password --execute="delete from asteriskcdrdb.cdr where calldate  < DATE_ADD(now(),INTERVAL -$max_days day) limit 100000"
mysql -v -uroot -p$mysql_root_password --execute="delete from asteriskcdrdb.cel where eventtime < DATE_ADD(now(),INTERVAL -$max_days day) limit 100000"

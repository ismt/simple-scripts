#!/bin/bash

source_log=./access.log
tmp_log=/tmp/squidforparse.log

mysql_dump=/tmp/mysql_dump.sql

cp $source_log $tmp_log

awk '{print "INSERT INTO squid (ip,bytes,link,trans,time,insert_date,tcp_status) \
             VALUES(\""$3"\","$5",\""$7"\",\""$9"\",from_unixtime("$1"),now(),\""$4"\");"};' < $tmp_log > $mysql_dump

mysql -h192.168.120.2 -usquid -p'L' squid_log < $mysql_dump

rm -f $tmp_log


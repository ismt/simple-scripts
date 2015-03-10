#!/bin/bash

cmd_options='--geometry 500x500+100+100 --radiolist "Выберите хост"'
while read line; do
  ip=$(echo  $line | cut -d\" -f2)
  hostname=$(echo  $line | cut -d\" -f4)
  cmd_options="${cmd_options} \"${ip}\" \"${hostname}\" \"off\""
done < СписокКомпов.txt

ip=$(echo $cmd_options | xargs kdialog)

if [ "$ip" != "" ] ;
then
  host_options=$(cat СписокКомпов.txt | grep $ip)

  options="$ip:5900 $(echo $host_options | cut -d\" -f6)"
  password=$(echo $host_options | cut -d\" -f8)
  
  kdialog --warningyesno "Только наблюдение ?"
  if [ "$?" == 0 ] ;
  then
    options='-ViewOnly '$options
  fi
  
  echo $password | vncpasswd -f > /tmp/vnc_temp_password

  vncviewer -passwd /tmp/vnc_temp_password $options 2>&1 | tee /tmp/vncviewer.log

  res=$(cat /tmp/vncviewer.log | grep 'Authentication failed from')
  if [ "$res" != "" ] ;
  then
    vncviewer $options  2>&1 | tee /tmp/vncviewer.log
  fi
fi
#!/bin/bash

function CheckPort
{
  CheckPortResult='!'
  netcat -w1 -z $1 $2 && CheckPortResult='+'
}

cmd_options='--geometry 500x500+100+100 --radiolist "Выберите хост"'
while read line
do
  if ! [[ "$line" =~ (^#) ]]
  then
    if [ "$(echo $line | tr -d ' ')" != '' ]
    then
      ip=$(echo  $line | cut -d\" -f2)

      CheckPort $(echo $ip | cut -d: -f1) $(echo $ip | cut -d: -f2)

      hostname=$(echo  $line | cut -d\" -f4)
      cmd_options="${cmd_options} \"${ip}\" \"$CheckPortResult ${hostname}\" \"off\""
    fi
  fi
done < СписокКомпов.txt

ip=$(echo $cmd_options | xargs kdialog)

if [ "$ip" != "" ] ;
then
  host_options=$(cat СписокКомпов.txt | grep $ip)

  options="$ip $(echo $host_options | cut -d\" -f6)"
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

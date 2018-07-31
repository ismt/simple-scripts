#!/bin/bash

function WakeUp
{
  if [ "$(whereis wol | awk '{ print $2 }' | tr -d \\n)" != "" ]
  then
    echo wol
    wol $1
  else
    if [ "$(whereis ether-wake | awk '{ print $2 }' | tr -d \\n)" != "" ]
    then
      echo ether-wake
      ether-wake $1
    fi
  fi

}

function GetArpTable
{
  echo Тащим arp таблицу
  nmap -sP -n 192.168.120.100-255 > /dev/null
  ip=$(arp -n | grep -i $result_mac | awk '{ print $1 }')
  echo $result_operation --- $result_mac --- $ip
}

function Shutdown
{
  GetArpTable
  ssh root@$ip 'shutdown -h now'
}

function Reboot
{
  GetArpTable
  ssh root@$ip 'reboot'
}

result_mac_file=$HOME/.dialog_result_mac
result_operation_file=$HOME/.dialog_operation
cmd_options='--menu Выберите\ хост 20 50 20'

while read line
do
  if ! [[ "$line" =~ (^#) ]] ;
  then
    mac_address=$(echo $line | awk '{ print $1 }')
    computer_name=$(echo $line | awk '{ print $2 }')
    cmd_options="${cmd_options} \"${mac_address}\" \"${computer_name}\" "
  fi
done < ./СписокХостов.txt

echo $cmd_options | xargs dialog 2>$result_mac_file

result_mac=$(cat $result_mac_file)
if [ "$result_mac" == "" ]
then
  clear
  echo Выход
  exit
fi

dialog --menu "Что сделать ?" 20 50 20 WakeUp Включить Shutdown Выключить Reboot Перезагрузить 2>$result_operation_file

result_operation=$(cat $result_operation_file)

if [ "$result_operation" == "" ]
then
  clear
  echo Выход
  exit
fi

clear
case $result_operation in
  WakeUp   ) WakeUp   $result_mac ;;
  Shutdown ) Shutdown $result_mac ;;
  Reboot   ) Reboot   $result_mac ;;
  *        ) echo Нихуя не знаю ;;
esac

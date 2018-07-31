#!/bin/bash

numlockx on
clear
x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")

res=`expr $x`x`expr $y - 0`

hostname_host=$(echo -n $(hostname | tr -d " "))
default_printer=$(awk "/^$hostname_host/ {print \$2}" $HOME/bin/printers_defaults.txt)
echo Принтер по умолчанию $default_printer

printers_in_system=$(lpstat -a | awk '{print $1}')

for i in $printers_in_system
do
  if [ "$i" == "$default_printer" ]
  then
    option="$option printer:$i "
  fi
done

for i in $printers_in_system
do
  if [ "$i" != "$default_printer" ]
  then
    if [ "$(echo $i | grep XP58$)" != "" ]
    then
      option="$option printer:$i:XP-58 " # Шоб легко настраивать чековый принтер
    else
      option="$option printer:$i "
    fi
  fi
done

xfreerdp -k 0x00000409 \
         --plugin cliprdr --ignore-certificate \
         --plugin rdpdr --data disk:Downloads:$HOME/Загрузки $option -- \
         -x 0x87 -D -g $res -z -a 16 \
         -u $USER -p t -n $hostname_host -s 'C:\Program Files\1Cv77\BIN\1cv7.exe' -T "1C $USER" 192.168.120.20

# Для корректной работы имя пользователя в psi, server.vd и линукс хосте должны быть одинаковые

# -n $user_name если надо задать имя хоста, нужно для 1С

# Включение программы исправления кодировки -s 'C:\start1c\start1c.bat

# Проброс COM порта --plugin rdpdr serial:COM6:/dev/ttyUSB0



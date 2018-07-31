#!/bin/bash

# Для переключения на другое соединение NetworkManager и поднятие проброса портов OpenSSH, этакая замена VPN

local_port='60000'
remote_port='3389'
remote_address='192.168.1.1'

ssh_server_port=61123
ssh_server_addr='1.1.1.1'
ssh_user='stas'
ssh_user_password=''

connection_main=Wired_connection
connection_reserv1=Utel
connection_reserv1_tty=/dev/ttyUSB2

if [ -c $connection_reserv1_tty ] ;
then
  echo Модем найден
else
  echo Нет модема, выход
  exit
fi
exit


trap "echo Возврат соединения ; nmcli con down id $connection_reserve ; nmcli con up id $connection_main" 1 2

echo Переключение на модем
nmcli con down id $connection_main && nmcli con up id $connection_reserve

echo Проброс портов ssh
sshpass -p "$ssh_user_password" ssh -4 -C -o 'CompressionLevel=5' -N -L 127.0.0.1:$local_port:$remote_address:$remote_port $ssh_user@$ssh_server_addr -p $ssh_server_port

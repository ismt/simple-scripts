#!/bin/bash

user_name=$1

if [ "$user_name" == "" ] ;
then
  echo Нужно имя пользователя deluser.sh user_name
  exit
fi

ssh_server=$(  awk '/^sftp/ {print $2}' /root/scripts/servers_address.txt)
ssh_user=$(    awk '/^sftp/ {print $3}' /root/scripts/servers_address.txt)
ssh_password=$(awk '/^sftp/ {print $4}' /root/scripts/servers_address.txt)

userdel -r $user_name
sshpass -p $ssh_password ssh $ssh_user@$ssh_server "rm -rf /home/client/$user_name"

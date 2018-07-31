#!/bin/bash

user_name=$1
if [ "$user_name" == "" ] ;
then
  echo Нужно имя пользователя adduser.sh user_name
  exit
fi

ssh_server=$(  awk '/^sftp/ {print $2}' /root/scripts/servers_address.txt)
ssh_user=$(    awk '/^sftp/ {print $3}' /root/scripts/servers_address.txt)
ssh_password=$(awk '/^sftp/ {print $4}' /root/scripts/servers_address.txt)

rsync_server=$(  awk '/^rsync/ {print $2}' /root/scripts/servers_address.txt)
rsync_user=$(    awk '/^rsync/ {print $3}' /root/scripts/servers_address.txt)
rsync_password=$(awk '/^rsync/ {print $4}' /root/scripts/servers_address.txt)

export RSYNC_PASSWORD=$rsync_password

rsync_options="--recursive --links -h --sparse --compress --delete-before --exclude=/home/$i/.cache --exclude=.csync_journal.db"

useradd -m $user_name &&
cp -v -f -p /root/.ssh/known_hosts /home/$user_name/.ssh &&
sshpass -p $ssh_password ssh $ssh_user@$ssh_server "mkdir -v -p /home/client/$user_name" &&
chown -c -R $user_name:users /home/$user_name &&
rsync $rsync_options /home/$user_name/ $rsync_user@$rsync_server::users_profiles_workstation/$user_name &&
passwd $user_name

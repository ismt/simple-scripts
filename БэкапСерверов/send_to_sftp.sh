#!/bin/bash

backup_server_ip=$1
backup_host_ip=$2
file_name=$3


for i in .tar.gz .tar.bz2 .tar.xz .tar.7z .tar
do
  file_name_base=$(basename $file_name $i)
  if [ $file_name_base != $file_name ];
  then
    #echo $file_name_base
    break
  fi
done

./echo_color.sh yellow Отправляем
sftp_file=./sftp_commands
echo "progress"                      >  $sftp_file
echo "-mkdir $backup_host_ip"        >> $sftp_file
echo "cd $backup_host_ip"            >> $sftp_file
echo "-rm $file_name_base.*"         >> $sftp_file
echo "put $file_name"              >> $sftp_file
echo "chmod 600 $file_name"          >> $sftp_file
echo "exit"                          >> $sftp_file

sftp -b $sftp_file -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -o "IdentityFile=./id_dsa" backup_user@$backup_server_ip


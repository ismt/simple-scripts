#!/bin/bash

# Сначала разлогиниться из client !

exit
rsync_server=$(  awk '/^rsync/ {print $2}' /root/scripts/servers_address.txt)
rsync_user=$(    awk '/^rsync/ {print $3}' /root/scripts/servers_address.txt)
rsync_password=$(awk '/^rsync/ {print $4}' /root/scripts/servers_address.txt)

export RSYNC_PASSWORD=$rsync_password
rsync -r -v --checksum --delete-before $rsync_user@$rsync_server::user_default_profile/ /home/client
chown -R client:users /home/client
echo Обработано

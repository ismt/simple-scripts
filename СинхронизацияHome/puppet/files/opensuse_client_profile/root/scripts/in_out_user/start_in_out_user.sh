#!/bin/bash

rsync_server=$(  awk '/^rsync/ {print $2}' /root/scripts/servers_address.txt)
rsync_user=$(    awk '/^rsync/ {print $3}' /root/scripts/servers_address.txt)
rsync_password=$(awk '/^rsync/ {print $4}' /root/scripts/servers_address.txt)
export RSYNC_PASSWORD=$rsync_password
user_=$PAM_USER
compress_level=9

if [ "$PAM_SERVICE" == "xdm" -a "$PAM_TYPE" == 'auth' -a "$user_" != client -a "$user_" != "" -a "$user_" != "root" ]
then
  echo
  echo in ------------------------------------------ Выполняем скрипт входа для $user_
  echo Параметры $PAM_SERVICE $PAM_TYPE $PAM_USER
  echo Получаем профиль пользователя $user_

  rsync -v --recursive --links -h --times --perms --compress --compress-level=$compress_level \
        --partial --partial-dir=partial-dir-rsync_get_user \
        --exclude=.xsession* --exclude=.Xauthority* --exclude=.vboxclient-* --delete-during \
        $rsync_user@$rsync_server::users_profiles_workstation/$user_/ /home/$user_

  chown -c -R $user_:users /home/$user_
fi

if [ "$PAM_SERVICE" == "xdm" -a "$PAM_TYPE" == 'close_session' -a "$user_" != client -a "$user_" != "" -a "$user_" != "root" ]
then
  echo
  echo out ------------------------------------------- Выполняем скрипт выхода для $user_
  echo Параметры $PAM_SERVICE $PAM_TYPE $PAM_USER
  echo Получаем профиль пользователя $user_

  rsync -v --recursive --links -h --times --perms --compress --compress-level=$compress_level \
        --partial --partial-dir=partial-dir-rsync_save_user \
        --exclude=.xsession* --exclude=.Xauthority* --exclude=.vboxclient-* --delete-during \
        /home/$user_/ $rsync_user@$rsync_server::users_profiles_workstation/$user_
fi

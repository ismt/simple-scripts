#!/bin/bash

# Скрипт для уменьшения пауз при выходе и входе пользователя
rsync_server=$(  awk '/^rsync/ {print $2}' /root/scripts/servers_address.txt)
rsync_user=$(    awk '/^rsync/ {print $3}' /root/scripts/servers_address.txt)
rsync_password=$(awk '/^rsync/ {print $4}' /root/scripts/servers_address.txt)

export RSYNC_PASSWORD=$rsync_password
PAUSE=0
ONLYCURRENTUSER=0

cd $(dirname $0)

# Распознаем опции -----------------------------------------------------------------------------------------------------------------------
ARGS=$(getopt -o w -l 'with-pause only-current-user' -n "$(basename $0)" -- "$@")
eval set -- "$ARGS"
while true ; do
  case "$1" in
    -w | --with-pause       ) PAUSE=1;           shift ;;
    -o | --only-current-user) ONLYCURRENTUSER=1; shift ;;
    --)                       shift ; break ;;
    *)                        echo "Internal error!" ; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------------------------------------------------
function Pause {
  if [ "$PAUSE" == "1" ] ;
  then
    pause_seconds=$RANDOM
    let "pause_seconds = $pause_seconds / 300"
    echo Пауза секунд $pause_seconds
    sleep $pause_seconds
  fi
}

# -----------------------------------------------------------------------------------------------------------------------
hostname=$(echo -n $(hostname | tr -d " "))
bw=$(grep "$hostname" regular_sync_hosts_speed.txt | awk '{print $2}')
if [ "$bw" == "" ] ;
then
  bwlimit=1000000
else
  bwlimit=$bw
fi
echo Скорость синхронизации килобайт $bwlimit

Pause

echo ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
date
current_user=$(echo -n $(who | grep -i console | cut -d" " -f1))
if [ "$current_user" != "" ]
then
  echo Залогинен $current_user , закидываем на сервер

  rsync --stats --bwlimit=$bwlimit --recursive --links --perms -h --times \
        --compress --compress-level=5 \
        --partial --partial-dir=partial-dir-regular_rsync --delete-during \
        /home/$current_user/ $rsync_user@$rsync_server::users_profiles_workstation/$current_user | grep 'Total bytes'
else
  echo Залогиненых нет
fi
echo
# --exclude=.cache --exclude=.thumbnails --exclude=.csync --exclude=.csync_journal.db --delete-excluded

if [ $ONLYCURRENTUSER != 0 ] ; then exit 0 ; fi

echo ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
users=$(grep home /etc/passwd | cut -d: -f1)
for i in $users
do
  echo ----------------------------------------------------------------------------------------------------------------------
  current_user=$(echo -n $(who | grep -i console | cut -d" " -f1))
  if [ "$i" == "client" -o "$i" == "$current_user" -o "$i" == "" ]
  then
    echo Пропускаем $i
  else
    Pause
    date
    echo Тащим с сервера $i

    su -l $i -s /bin/bash -c "export RSYNC_PASSWORD=$rsync_password ;
                              rsync --stats --bwlimit=$bwlimit --recursive --links -h --times --perms \
			      --compress --compress-level=5 \
			      --partial --partial-dir=partial-dir-regular_rsync --delete-during \
			      $rsync_user@$rsync_server::users_profiles_workstation/$i/ /home/$i | grep Total\ bytes"

    #chown -c -R $i:users /home/$i
    echo Всего профиль --- $(du -sh /home/$i)
  fi
  echo
done


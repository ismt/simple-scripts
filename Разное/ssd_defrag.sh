#!/bin/bash

if [[ -z "$*" ]]
then
    echo "Задайте устройство, например /dev/sda1"
    exit 0
fi

device="$1"

blk_id=$(blkid "$device")

echo "Дефрагментация $blk_id"

exists_ext4=$(echo "$blk_id" | grep 'TYPE="ext4"')
exists_xfs=$(echo "$blk_id" | grep 'TYPE="xfs"')

if [[ -n "$exists_ext4" ]]
then
    e4defrag "$device" > /dev/null

    # Принудительно каждый файл, команда выше работает не до конца
    # find / -xdev -type f -exec e4defrag -- "{}" \; > /dev/null

elif [[ -n "$exists_xfs" ]]
then
    xfs_fsr "$device" > /dev/null

else
    echo "Файловая система не определена"

fi

fstrim /



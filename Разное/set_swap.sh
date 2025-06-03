#!/bin/bash

swap_file=/srv/swapfile

fallocate -l 5G "$swap_file"

chmod 600 "$swap_file"
mkswap "$swap_file"
swapon "$swap_file"

printf "\n" >>/etc/fstab

echo "${swap_file} swap swap defaults 0 0" >>/etc/fstab

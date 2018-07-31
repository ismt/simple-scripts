#!/bin/bash

# Жесткая перезагрузка, аналог ресета
echo "Сохранение буфера диска, sync"
sync
sleep 5 # По слухам надо дать данным сохраниться
echo "Перезагрузка"
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger

# Жесткое выключение
#echo 1 > /proc/sys/kernel/sysrq
#echo o > /proc/sysrq-trigger

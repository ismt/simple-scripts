#!/bin/bash

echo Список дисплеев
#ps -aux | grep -i xorg
w -hs | grep -i xdm

killall x11vnc || true
x11vnc -display :0 -ncache 10 -noxdamage -xrandr -safer -forever -rfbauth ~/.x11vnc/passwd > $HOME/.x11vnc/x11vnc.log 2>&1


# Установить x11vnc
# Создать пароль  mkdir ~/.x11vnc ; x11vnc -storepasswd pass ~/.x11vnc/passwd
# Подключаться vncviewer -NoJPEG -compresslevel 5 host:5900

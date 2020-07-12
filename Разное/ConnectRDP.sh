#!/bin/sh

numlockx on

x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")

res=`expr ${x}`x`expr ${y} - 0`

echo ${res}

xfreerdp -k 0x00000409 --plugin cliprdr --ignore-certificate --plugin rdpdr --data disk:Downloads:$HOME/Загрузки -- -x 0x87 -D -g ${res} -z -a 16 -u user -p pass 127.0.0.1
# --no-bmp-cache
# Windows 7 -x 0x87
#This hex value is actually a combination of defined bit flags. After some tinkering I found that the hex value 0×80 will enable font smoothing for the connection.
# The file constants.h of the rdesktop sources contains these flags:
#define RDP5_DISABLE_NOTHING    0x00
#define RDP5_NO_WALLPAPER   0x01
#define RDP5_NO_FULLWINDOWDRAG  0x02
#define RDP5_NO_MENUANIMATIONS  0x04
#define RDP5_NO_THEMING     0x08
#define RDP5_NO_CURSOR_SHADOW   0x20
#define RDP5_NO_CURSORSETTINGS  0x40    /* disables cursor blinking */

#So, naturally an additional flag constant can be defined like this:
#define RDP5_ENABLE_FONT_SMOOTHING 0x80


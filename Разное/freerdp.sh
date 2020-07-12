#!/bin/bash

numlockx on

x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")

res=`expr ${x}`x`expr ${y} - 0`

echo ${res}

#rdesktop -N -D -x 0x81 -k en-us -g $res -z -a 24 -u u20 -p u20 192.168.1.248
#xfreerdp --plugin cliprdr -x 0x81*0x04 -g $res -z -a 32 -u u20 -p u20 192.168.1.248

xfreerdp --plugin cliprdr --ignore-certificate -x 0x87 -D -g ${res} -z -a 32 -u S -p 'pass' 192.168.2.1

# --no-bmp-cache
# Windows 7
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

#The file rdesktop.c would have to be extended preferably with an additional argument that controls the font smoothing.
# If you want to use font smoothing with rdesktop now you have to combine the flags (bitwise OR, addition will do too) and specify the result via the -x switch.

#Here is the workaround for the three defaults mentioned above:
#
#rdesktop -x 0x8F mywinserver   # equals the modem default + font smoothing
#rdesktop -x 0x81 mywinserver   # equals the broadband default + font smoothing
#rdesktop -x 0x80 mywinserver   # equals the LAN default + font smoothin 
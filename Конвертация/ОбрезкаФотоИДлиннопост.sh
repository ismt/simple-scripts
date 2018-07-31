#!/bin/bash
#http://www.imagemagick.org/script/command-line-options.php
#Конвертация из pdf convert -define png:compression-level=9 -density 300 -filter Lanczos2 SERVER_Razgovornik.pdf single%d.png

function ClearDir {
  rm -r -f $1
  mkdir -p $1
  echo Очищено $1
}

clear
ROOT_PATH=$HOME/__КартинкиВДлиннопост
mkdir -p $ROOT_PATH
cd $ROOT_PATH

# Получаем размер экрана в KDE
x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")
res=`expr $x`x`expr $y - 0`+`expr $x / 2`+`expr $y / 2`

Source=$(kdialog --geometry $res --getexistingdirectory  "$HOME"  )
if [ "$Source" == "" ]
then
  echo Ничего не выбрано, выход
  exit 0
fi

clear
TargetFolfer=$ROOT_PATH/Обработка
ItogFolder=$ROOT_PATH/ИтогДлиннопост
PngInterlace=0

ClearDir $ItogFolder
ClearDir $TargetFolfer

Width=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$Source" | grep streams.stream.0.width= | awk -F"=" '{ print $2 }')
Height=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$Source" | grep streams.stream.0.height= | awk -F"=" '{ print $2 }')
WidthMax=600
HeightMax=x650
DefaultJpgConvertOptions='-interlace jpeg -define jpeg:optimize-coding=on -define jpeg:dct-method=float -alpha Remove -background rgb(255,255,255) -monitor'


Stretch=$(kdialog --geometry 800x500+200+200 --radiolist "Подогнать к ширине ?" \
                                                             300">"  "300"  off  \
                                                             350">"  "350"  off  \
                                                             400">"  "400"  off  \
                                                             450">"  "450"  off  \
                                                             500">"  "500"  off  \
                                                             550">"  "550"  off  \
                                                             600">"  "600"  on  \
                                                             700">"  "700"  off  \
                                                             800">"  "800"  off  \
                                                             900">"  "900"  off  \
                                                             1000">"  "1000"  off  \
                                                             1100">"  "1100"  off  \
                                                             1200">"  "1200"  off  \
                                                             1300">"  "1300"  off  \
                                                             1400">"  "1400"  off  \
                                                             100000">"  "Нет" off \
                                                             )
CropDown=$(kdialog --geometry 800x500+200+200 --inputbox "Отрезать снизу "  0  )

#echo $Stretch && sleep 1000
#Изменяем размер, отрезаем лишнее снизу если надо CropDown
convert -monitor -alpha Remove -background "rgb(255,255,255)" -define png:compression-level=9 -define png:format=png24 -crop "$Width"x"$Height"+0-$CropDown -filter Lanczos -resize "$Stretch" -set filename:base '%t' "$Source/*.jpeg" "$Source/*.jpg" "$Source/*.png" "$Source/*.tif" $TargetFolfer/'%[filename:base].png'
montage  $TargetFolfer/*.png -tile 1 -geometry +0+5 -alpha off $ItogFolder/Длиннопост.png

echo
FileLength=$(du $ItogFolder/Длиннопост.png | cut -f1)
echo Длина файла $FileLength Кб
if [ $FileLength -gt 7500 ];
then
  convert -quality 95 $DefaultJpgConvertOptions  $ItogFolder/Длиннопост.png $ItogFolder/Длиннопост.jpg
fi
optipng -i 0 -o3 -clobber $ItogFolder/Длиннопост.png
optipng -i 1 -o1 $ItogFolder/Длиннопост.png -out $ItogFolder/Длиннопост_adam7.png

echo Готово

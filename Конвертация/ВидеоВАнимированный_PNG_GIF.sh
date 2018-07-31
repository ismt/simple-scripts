#!/bin/bash
#http://www.imagemagick.org/script/convert.php

#zypper in libpng12-0-32bit

SCRIPTS_DIR=$(cd $(dirname $0) && pwd)
ROOT_PATH=$HOME/__КонвертацияВидео_в_GIF
mkdir -p $ROOT_PATH
cd $ROOT_PATH

function ClearDir {
  rm -r -f $1
  mkdir -p $1
  echo Очищено $1
}

function CheckEmptyString
{
  str=$(echo $1 | tr -d ' ')
  if [ "$str" == "" ]
  then
    echo Ничего не выбрано, выход
    exit 0
  fi
}

SourceDirPng=$ROOT_PATH/ИсходныеКадры
ResizedPNG=$ROOT_PATH/ResizedPNG
ItogFiles=$ROOT_PATH/ИтогКонвертации

x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")
res=`expr $x`x`expr $y - 0`+`expr $x / 2`+`expr $y / 2`

SourceVideo=$(kdialog --geometry $res --getopenfilename  "$HOME"  )

clear
CheckEmptyString $SourceVideo

Stretch=$(kdialog --geometry 800x500+200+200 --radiolist "Ширина гифки ?" \
                                                             300  "300"  off  \
                                                             350  "350"  off  \
                                                             400  "400"  off  \
                                                             450  "450"  off  \
                                                             500  "500"  off  \
                                                             550  "550"  off  \
                                                             600  "600"  on  \
                                                             700  "700"  off  \
                                                             800  "800"  off  \
                                                             900  "900"  off  \
                                                             1000  "1000"  off  \
                                                             1100  "1100"  off  \
                                                             1200  "1200"  off  \
                                                             1300  "1300"  off  \
                                                             1400  "1400"  off  \
                                                             100000  "Нет" off \
                                                             )
CheckEmptyString  $Stretch                                                       
                                                             
clear
ClearDir $ItogFiles
ClearDir $SourceDirPng
ClearDir $ResizedPNG


FrameRateSlash=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.0.avg_frame_rate= | awk -F"\"" '{ print $2 }')
SourceFrameRate=$(echo "scale=0;$FrameRateSlash" | bc -l)
Width=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.0.width= | awk -F"=" '{ print $2 }')
Height=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.0.height= | awk -F"=" '{ print $2 }')
target=$ItogFiles/res_png_to_apng.png

echo Директория результат png $SourceDirPng
echo Куда $target
echo Веременные файлы $SourceDirPng
echo "Частота кадров видео --- $SourceFrameRate"

SourceFrameRate=$(kdialog --inputbox 'Частота кадров (из ролика)' $SourceFrameRate)
echo "Частота кадров GIF   --- 1/$SourceFrameRate"

echo
echo Вытаскиваем из файла кадры
ffmpeg -i "$SourceVideo" -loglevel warning -r $SourceFrameRate -f image2 $SourceDirPng/image_%05d.png
echo Есть

count_in_dir=$(ls -f $SourceDirPng/*.png | wc -l)
echo Извлечено кадров $count_in_dir

count=0
find $SourceDirPng -iname "*.png" | while read file ; do
  convert $file -define png:format=png24 -define png:compression-level=1 -filter Lanczos -resize $Stretch">" -dither FloydSteinberg $ResizedPNG/$(basename $file)
  let "count = count + 1"
  echo -n -e "Обработка --------> $count из $count_in_dir\r"
done
echo

echo Конвертация, ждём
$SCRIPTS_DIR/apngasm/apngasm $target  $ResizedPNG/*.png 1 $SourceFrameRate > /dev/null 2>&1
$SCRIPTS_DIR/apng2gif/apng2gif $target $target.gif

play -q -v 10 $SCRIPTS_DIR/Файлы/kolokol.ogg
sleep 1
play -q -v 10 $SCRIPTS_DIR/Файлы/kolokol.ogg

#!/bin/bash
# http://www.imagemagick.org/script/command-line-options.php
# zypper in ffmpeg optipng
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White

SCRIPTS_DIR=$(cd $(dirname $0) && pwd)
ROOT_PATH=$HOME/__КонвертацияКартинок
mkdir -p $ROOT_PATH
cd $ROOT_PATH

function ClearDir {
  rm -r -f $1
  mkdir -p $1
  echo Очищено $1
}

x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")
res=`expr $x`x`expr $y - 0`+`expr $x / 2`+`expr $y / 2`

Source=$(kdialog --geometry $res --getopenfilename  "$HOME"  )
if [ "$Source" == "" ]
then
  echo Ничего не выбрано, выход
  exit 0
fi
clear
Width=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$Source" | grep streams.stream.0.width= | awk -F"=" '{ print $2 }')
Height=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$Source" | grep streams.stream.0.height= | awk -F"=" '{ print $2 }')

WidthPikabuMax=1600
WidthPikabuMaxReal=600 # Фактическая ширина картинки на сайте
HeightOptimal=680
WidthOptimal=800
WidthOptimal2=600
ObrabotkaFolder=$ROOT_PATH/Обработка
ItogFolder=$ROOT_PATH/ИтогКонвертации
DefaultJpgConvertOptions='-interlace jpeg -define jpeg:optimize-coding=on -define jpeg:dct-method=float -alpha Remove -background rgb(255,255,255) -monitor'
DefaultPngConvertOptions='-define png:compression-level=9 -define png:format=png32 -filter Lanczos'

ClearDir $ObrabotkaFolder
ClearDir $ItogFolder
cp "$Source" "$ObrabotkaFolder/Исходник_$(basename "$Source")"
echo -e "${txtwht}"

convert -define png:compression-level=2 -define png:format=png32 "$Source" $ObrabotkaFolder/png_first.png
cp $ObrabotkaFolder/png_first.png $ItogFolder/"$Width"x"$Height"_исходник.png

if [ $Width -gt $WidthPikabuMax ];
then
  echo -e "${txtylw}"Разрешение слишком большое для Пикабу, перегоняем в ширину $WidthPikabuMax с фильтрами резкости"${txtwht}"
  convert $DefaultPngConvertOptions -resize $WidthPikabuMax">" $ObrabotkaFolder/png_first.png $ItogFolder/"$WidthPikabuMax"_ширина_пикабу.png
fi

if [ "$Height" -gt $HeightOptimal ];
then
  echo -e "${txtylw}"Делаем оптимальную картинку по высоте $HeightOptimal"${txtwht}"
  convert $DefaultPngConvertOptions -resize x$HeightOptimal $ObrabotkaFolder/png_first.png $ItogFolder/"$HeightOptimal"_высота.png
fi

if [ "$Width" -gt $WidthOptimal ];
then
  echo -e "${txtylw}"Делаем оптимальную картинку по ширине $WidthOptimal"${txtwht}"
  convert $DefaultPngConvertOptions -resize $WidthOptimal $ObrabotkaFolder/png_first.png $ItogFolder/"$WidthOptimal"_ширина.png
fi

if [ "$Width" -gt $WidthOptimal2 ];
then
  echo -e "${txtylw}"Делаем оптимальную картинку по ширине $WidthOptimal2"${txtwht}"
  convert $DefaultPngConvertOptions -resize $WidthOptimal2 $ObrabotkaFolder/png_first.png $ItogFolder/"$WidthOptimal2"_ширина.png
fi

convert $ObrabotkaFolder/png_first.png -resize x250 -filter Cubic -font "$SCRIPTS_DIR/Файлы/AGRevueCyr Italic.ttf" -pointsize 32 -fill white -stroke black -gravity SouthWest -annotate +5+5 "$Width"x"$Height" -monitor $ItogFolder/Предпросмотр.png

FileLength=$(du $ObrabotkaFolder/png_first.png | cut -f1)
if [ $FileLength -gt 7800 ];
then
  echo
  echo -e "${txtylw}"Файл слишком большой, пробуем jpeg"${txtwht}"
  echo -e "${txtylw}"Качесто jpeg 100"${txtwht}"
  convert -quality 100 $DefaultJpgConvertOptions "$Source" $ItogFolder/jpg_quality_100_"$Width"x"$Height".jpg
  echo -e "${txtylw}"Качесто jpeg 98"${txtwht}"
  convert -quality 98  $DefaultJpgConvertOptions "$Source" $ItogFolder/jpg_quality_98_"$Width"x"$Height".jpg
  echo -e "${txtylw}"Качесто jpeg 95"${txtwht}"
  convert -quality 95  $DefaultJpgConvertOptions "$Source" $ItogFolder/jpg_quality_95_"$Width"x"$Height".jpg
  optipng -i 0 -o3 -preserve  -clobber $ItogFolder/*.png
else
  echo -e "${txtylw}"Оптимизируем"${txtwht}"
  optipng -i 1 -o3 -preserve  -clobber $ItogFolder/*.png
fi

echo -e "${txtgrn}"Готово

#!/bin/bash

#http://ru.wikipedia.org/wiki/VP8
#
# http://www.calculate-linux.ru/boards/40/topics/5294
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White

SCRIPTS_DIR=$(cd $(dirname $0) && pwd)
#ABSOLUTE_FILENAME=$(readlink -e "$0")

ROOT_PATH=$HOME/__КонвертацияВидео
mkdir -p $ROOT_PATH
cd $ROOT_PATH

test_pict_compress_level=3

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
    clear
    echo Ничего не выбрано, выход
    exit 0
  fi
}

ProcessorCores=$(grep -c '^processor' /proc/cpuinfo)

function EncodeWebM {
  rm -f "$4"
  echo -e "${txtylw}Из ${txtgrn}$2 ${txtwht}"
  echo -e "${txtylw}В ${txtgrn}$4 ${txtwht}"
  passlogfile=./ИтогКонвертации/`basename "$2"`
  ffmpeg \
  -stats \
  -benchmark \
  -y \
  -i "$2" \
  -loglevel warning \
  -f webm \
  -strict -2 \
  -vcodec libvpx \
  -vb $3k \
  -acodec libvorbis \
  -ab $SourceBitRateAudio \
  -threads $ProcessorCores \
  -pass "$1" \
  -passlogfile "$passlogfile" \
  -g $gop \
  -keyint_min $keyint_min \
  -bt 50 \
  -pix_fmt yuv420p \
  -auto-alt-ref 1 \
  -lag-in-frames 25 \
  -keyint_min 0 \
  -slices 4 \
  -mb_threshold $5 \
  -deadline best \
  -quality best \
  "$4"
  return 0
}

function EncodeH264 {
  rm -f "$4"
  echo -e "${txtylw}Из ${txtgrn}$2 ${txtwht}"
  echo -e "${txtylw}В ${txtgrn}$4 ${txtwht}"
  passlogfile=./ИтогКонвертации/`basename "$2"`
  ffmpeg \
  -stats \
  -benchmark \
  -y \
  -i "$2" \
  -loglevel warning \
  -f mp4 \
  -strict -2 \
  -vcodec libx264 \
  -vb $3k \
  -acodec aac \
  -ab $SourceBitRateAudio \
  -threads $ProcessorCores \
  -pass "$1" \
  -passlogfile "$passlogfile" \
  -preset placebo \
  -g $gop \
  -keyint_min $keyint_min \
  -bt 50 \
  -refs 4 \
  -bf 1 \
  -b_strategy 0 \
  -psy 0 \
  -pix_fmt yuv420p \
  "$4"
  return 0
  #-ar 48000
}

function EncodeH264Flac {
  rm -f "$4"
  echo -e "${txtylw}Из ${txtgrn}$2 ${txtwht}"
  echo -e "${txtylw}В ${txtgrn}$4 ${txtwht}"
  passlogfile=./ИтогКонвертации/`basename "$2"`
  ffmpeg \
  -stats \
  -benchmark \
  -y \
  -i "$2" \
  -loglevel warning \
  -f matroska \
  -strict -2 \
  -vcodec libx264 \
  -vb $3k \
  -acodec flac \
  -ar 48000 \
  -compression_level 8 \
  -prediction_order_method search \
  -threads $ProcessorCores \
  -pass "$1" \
  -passlogfile "$passlogfile" \
  -preset placebo \
  -g $gop \
  -keyint_min $keyint_min \
  -bt 50 \
  -refs 4 \
  -bf 1 \
  -b_strategy 0 \
  -psy 0 \
  -pix_fmt yuv420p \
  "$4"
  return 0
}

function EncodeWebMW {
  if [ $EncodePassCount = 1 ]
  then
    echo -e "${txtred}1 проход ${txtwht}"
    EncodeWebM 0 "$1" $2 "$OutVideo" "$3"
  else
    count=1
    while [ "$count" -le "$EncodePassCount" ]
    do
      echo -e "${txtred}$count проход ${txtwht}"
      EncodeWebM $count "$1" $2 "$OutVideo" "$3"
      let "count = count + 1"
    done
  fi
  return 0
}

function EncodeH264W {
  BitrateName=_Bitrate_$2

  if [ $EncodePassCount = 1 ]
  then
    echo -e "${txtred}1 проход ${txtwht}"
    EncodeH264 0 "$1" $2 "$OutVideo"
  else
    count=1
    while [ "$count" -le "$EncodePassCount" ]
    do
      echo -e "${txtred}$count проход ${txtwht}"
      EncodeH264 $count "$1" $2 "$OutVideo"
      let "count = count + 1"
    done
  fi
}

function EncodeH264FlacW {
  BitrateName=_Bitrate_$2

  if [ $EncodePassCount = 1 ]
  then
    echo -e "${txtred}1 проход ${txtwht}"
    EncodeH264Flac 0 "$1" $2 "$OutVideo"
  else
    count=1
    while [ "$count" -le "$EncodePassCount" ]
    do
      echo -e "${txtred}$count проход ${txtwht}"
      EncodeH264Flac $count "$1" $2 "$OutVideo"
      let "count = count + 1"
    done
  fi
}

x=$(xprop -root _NET_WORKAREA | awk '{print $5}' | tr "," " ")
y=$(xprop -root _NET_WORKAREA | awk '{print $6}' | tr "," " ")
res=$(expr $x)x$(expr $y - 0)+$(expr $x / 2)+$(expr $y / 2)

ClearDir $ROOT_PATH/ИтогКонвертации/
ClearDir $ROOT_PATH/ПроверкаКачества/

# Путь к исходному файлу
SourceVideo=$(kdialog --geometry $res --getopenfilename  "$HOME"  )
CheckEmptyString $SourceVideo

CodecSelect=$(kdialog --geometry 800x500+200+200 --radiolist "Выберите кодек" \
                                                   1 "VP8 Webm" off \
                                                   2 "H264 mp4" off \
                                                   3 "H264 mkv и Flac звук без потерь" on \
                                                   5 "VP8 Webm видео без движения (лучше сжатие)" off \
                                                   )
CheckEmptyString $CodecSelect

BitRateVideoSelect=$(kdialog --geometry 800x500+200+200 --radiolist "Выберите битрейт"  \
                                                             250  "250"  off \
                                                             350  "350"  off \
                                                             450  "450"  off \
                                                             500  "500"  off \
                                                             1000 "1000" off \
                                                             1500 "1500" off \
                                                             1800 "1800" off \
                                                             2000 "2000" off \
                                                             2500 "2500" on \
                                                             3000 "3000" off \
                                                             3500 "3500" off \
                                                             4000 "4000" off \
                                                             4500 "4500" off \
                                                             5000 "5000" off \
                                                             8000 "8000" off)

CheckEmptyString $BitRateVideoSelect

EncodePassCount=$(kdialog --geometry 800x500+200+200 --radiolist "Сколько проходов кодирования ?" \
                                                             1  "1"  off \
                                                             2  "2"  on \
                                                             )
CheckEmptyString $EncodePassCount
# Разрешение видео соответствует исходному
# Внимание, наюлюдался глюк с воспроизведением webm в Firefox 22, воспроизведение соскакивало в конец ролика, наблюдалось при кодировании в mkv, из mp4 все нормально

FrameRateSlash=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.0.avg_frame_rate= | awk -F"\"" '{ print $2 }')
SourceFrameRate=$(echo "scale=3;$FrameRateSlash" | bc -l)
SourceBitRateAudio=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.1.bit_rate= | awk -F"\"" '{ print $2 }')
Width=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.0.width= | awk -F"=" '{ print $2 }')
Height=$(ffprobe -v 0 -print_format flat -show_format -show_streams "$SourceVideo" | grep streams.stream.0.height= | awk -F"=" '{ print $2 }')

clear
echo -e "${txtylw}Частота кадров ${txtgrn}$SourceFrameRate $FrameRateSlash${txtwht}"
keyint_min=$(echo $SourceFrameRate | awk -F"." '{ print $1 }')
let "keyint_min=keyint_min + 1"
let "keyint_min=keyint_min / 2"
let "gop=keyint_min * 10"

if [ "$SourceBitRateAudio" == "N/A" ] || [ "$SourceBitRateAudio" -gt "256000" ]
then
  SourceBitRateAudio=$(kdialog --geometry 800x500+200+200 --radiolist "Выберите битрейт аудио"  \
                                                             96k   "96"   off \
                                                             128k  "128"  off \
                                                             160k  "160"  off \
                                                             192k  "192"  on \
                                                             256k  "256"  off \
                                                             320k  "320"  off \
                                                             )
else
  SourceBitRateAudio=$(echo "($SourceBitRateAudio / 1000 ) + (($SourceBitRateAudio % 1000) + 500) / 1000" | bc )
  SourceBitRateAudio="$SourceBitRateAudio"k
fi

echo -e "${txtylw}Ядер проца ${txtgrn}$ProcessorCores ${txtwht}"
echo -e "${txtylw}GOP ${txtgrn}$gop${txtwht}"
echo -e "${txtylw}keyint_min ${txtgrn}$keyint_min ${txtwht}"
echo -e "${txtylw}Битрейт видео ${txtgrn}$BitRateVideoSelect ${txtwht}"
if [ "$CodecSelect" == "3" ]
then
  echo -e "${txtylw}Аудио ${txtgrn}без потерь flac${txtwht}"
else
  echo -e "${txtylw}Битрейт аудио ${txtgrn}$SourceBitRateAudio ${txtwht}"
fi

VremyaKadra=00:00:35 # Время откуда брать тестовый кадр
FirstPict=./ПроверкаКачества/`basename "$SourceVideo"`_Исходник_"$VremyaKadra".png
echo -e "${txtylw}Сохраняем кадр из исходного видео из ${txtgrn}$SourceVideo ${txtylw}в ${txtgrn}$FirstPict${txtwht}"
ffmpeg -loglevel warning -i "$SourceVideo"  -an -ss $VremyaKadra -vframes 1 -y "$FirstPict"
echo -e "${txtylw}Сжимаем для верности ${txtgrn}$FirstPict ${txtwht}"
optipng -o$test_pict_compress_level -clobber "$FirstPict" > /dev/null 2>&1

for Bitrate in $BitRateVideoSelect
do
  BitrateName=_Bitrate_$Bitrate
  if [ "$CodecSelect" == "1" ]
  then
    OutVideo=./ИтогКонвертации/`basename "$SourceVideo"`$BitrateName.webm
    EncodeWebMW "$SourceVideo" $Bitrate '0'
  fi

  if [ "$CodecSelect" == "5" ]
  then
    OutVideo=./ИтогКонвертации/`basename "$SourceVideo"`$BitrateName.webm
    EncodeWebMW "$SourceVideo" $Bitrate '1000'
  fi

  if [ "$CodecSelect" == "2" ]
  then
    OutVideo=./ИтогКонвертации/`basename "$SourceVideo"`$BitrateName.mp4
    EncodeH264W "$SourceVideo" $Bitrate
  fi

  if [ "$CodecSelect" == "3" ]
  then
    OutVideo=./ИтогКонвертации/`basename "$SourceVideo"`$BitrateName.mkv
    EncodeH264FlacW "$SourceVideo" $Bitrate
  fi
  FirstPict=./ПроверкаКачества/`basename "$OutVideo"`_"$VremyaKadra".png
  echo -e "${txtylw}Сохраняем кадр из готового видео из ${txtgrn}$OutVideo ${txtylw}в ${txtgrn}$FirstPict${txtwht}"
  ffmpeg -loglevel warning -i "$OutVideo" -an -ss $VremyaKadra -vframes 1 -y "$FirstPict"
  optipng -o$test_pict_compress_level -clobber "$FirstPict"> /dev/null 2>&1
done

echo -e "${txtgrn}Готово "

play -q -v 10 $SCRIPTS_DIR/Файлы/kolokol.ogg
sleep 1
play -q -v 10 $SCRIPTS_DIR/Файлы/kolokol.ogg

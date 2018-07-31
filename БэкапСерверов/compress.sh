#!/bin/bash

# ./compress.sh dir 9 tar.bz2 test

source=$1
compression_level=$2
arc_type=$3
out_file_name=$4

./echo_color.sh yellow "Подсчет размера $source ..."
folder_length_bytes=$(du -s $source | cut -f1)
let "folder_length_bytes=$folder_length_bytes*1000"
let "folder_length=$folder_length_bytes/1048576"
./echo_color.sh yellow "Размер $source ~$folder_length MiB --- уровень сжатия (0-9) - $compression_level --- тип архива $arc_type"

./echo_color.sh yellow "Создаем tar"
if [ -f /usr/bin/pv ] ;
then
  ionice -c3 tar --sparse -cf - $source | pv -s $folder_length_bytes > $out_file_name.tar
else
  ionice -c3 tar --sparse -cf $out_file_name.tar $source
fi

function Compress {
  if [ -f /usr/bin/pv ] ;
  then
    pv "$3" | nice -n 18 $1 $2 > "$4"
  else
    nice -n 18 $1 $2 "$3"
  fi
}

./echo_color.sh yellow Сжимаем
case $arc_type in
"tar.gz" )
  Compress gzip  -$compression_level "$out_file_name.tar" "$out_file_name.tar.gz"
  ;;
"tar.xz" )
  Compress xz    -$compression_level "$out_file_name.tar" "$out_file_name.tar.xz"
  ;;
"tar.bz2" )
  Compress bzip2 -$compression_level "$out_file_name.tar" "$out_file_name.tar.bz2"
  ;;
"tar.7z" )
  ./echo_color.sh yellow "Многопоточно"
  nice -n 18 7za a -t7z -m0=LZMA2 -mx=$compression_level "$out_file_name.tar.7z" "$out_file_name.tar"
  ;;
"tar" )
  ./echo_color.sh yellow 'Без компрессии'
  ;;
* )
  ./echo_color.sh red "Не знаю такого типа архива"
  exit 1
  ;;
esac

exit 0

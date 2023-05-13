#!/bin/bash

trap 'echoПрервано,выход;
exit1' 2 20

function CleanDir {
  base_dir=$1

  start_base_dir=$(echo ${base_dir:0:${#operate_with_dir}})
  if [[ $start_base_dir != "$operate_with_dir" ]]; then
    echo Нельзя, можно только в директории $operate_with_dir
    exit
  fi

  count_dirs=$(ls -F "$base_dir" | grep \/$ | wc -l)
  max_dirs=$2
  count=0
  let "count_res = $count_dirs - $max_dirs"
  cd "$base_dir"
  echo Количество директорий ${count_dirs} , удалить ${count_res} старых в ${base_dir}
  ls -t -r "$base_dir" | while read file; do
    if [[ ${count} -lt ${count_res} ]]; then
      if [[ -d "$base_dir/$file" ]]; then
        echo Директория, удаляем "$base_dir/$file"
        rm -f -r "$base_dir/$file"
      else
        echo Файл, пропускаем "$base_dir/$file"
        let "count=$count-1"
      fi
    fi
    let "count=$count+1"
  done
}operate_with_dir=/backup/goods
# 1 Параметр директория, 2 максимальное количество поддиректорий, если больше, удаляются самые старые
CleanDir /backup/goods/ttttttt/sdsdf 15
CleanDir /backup/fileserver 15

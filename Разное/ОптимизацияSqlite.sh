#!/bin/bash

clear
free_length_=0
find ~/ -size +100k -type f -print0 | \
  while read -d '' FILE; do
    abs_file_name=$(readlink -f "$FILE")
    headfile=`head -c 15 "$abs_file_name" 2> /dev/null`
    if [ "$headfile" = "SQLite format 3" ]; then
      file_size_do=`du -b "$abs_file_name"|cut -f1`;
      sqlite3 "$abs_file_name" "VACUUM; REINDEX;" #> /dev/null 2>&1
      file_size_posle=`du -b "$abs_file_name"|cut -f1`;
      free_length_=$(echo  "scale=0; $free_length_+($file_size_do-$file_size_posle)"|bc -l)
      echo $free_length_ > /tmp/free_length_.txt
      echo "Процент " $(echo "scale=2; ($file_size_posle/$file_size_do)*100"|bc -l) "$abs_file_name"
    fi
  done
free_length_=$(cat /tmp/free_length_.txt)
let "free_length_ = free_length_ / 1024"
echo $free_length_ Килобайт освобождено
exit 0

 #~/

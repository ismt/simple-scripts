#!/bin/bash

SCRIPTS_DIR=$(cd $(dirname $0) && pwd)
ROOT_PATH=__СкачатьСайт
mkdir -p $ROOT_PATH
cd $ROOT_PATH

clear
function ClearDir {
  rm -r -f $1
  mkdir -p $1
  echo Очищено $1
}

Source=$(kdialog --textinputbox  "Введите сайт" "" 500 50 )
if [ "$Source" == "" ]
then
  echo Ничего не выбрано, выход
  exit 0
fi

ClearDir ./Сайт
cd ./Сайт
wget -r -k -p -l 5 "$Source"

$SCRIPTS_DIR/color_echo.sh Зелёный 'Готово'

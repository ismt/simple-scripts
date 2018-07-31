#!/bin/bash

function ColorEcho
{
  color=$(echo $1 | awk '{print tolower($0)}')
  case $color in
    green       | зелёный        | зеленый        ) echo -e "\e[32m$2\e[0m" ;;
    light_green | светло_зелёный | светло_зеленый ) echo -e "\e[1;32m$2\e[0m" ;;
    yellow      | жёлтый         | желтый         ) echo -e "\e[1;33m$2\e[0m" ;;
    red         | красный                         ) echo -e "\e[31m$2\e[0m" ;;
    light_red   | светло_красный                  ) echo -e "\e[1;31m$2\e[0m" ;;
    * ) echo -e "$2" ;;
  esac

}

ColorEcho "$1" "$2"

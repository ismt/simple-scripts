#!/bin/bash

case $1 in
  green       | зелёный )                         echo -e "\e[32m$2\e[0m" ;;
  light_green | светло_зелёный | светло_зеленый ) echo -e "\e[1;32m$2\e[0m" ;;
  red         | красный )                         echo -e "\e[31m$2\e[0m" ;;
  yellow      | жёлтый )                          echo -e "\e[1;33m$2\e[0m" ;;
  light_red   | светло_красный )                  echo -e "\e[1;31m$2\e[0m" ;;
  * )                                             echo "$2" ;;
esac

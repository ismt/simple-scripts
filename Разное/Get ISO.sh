#!/bin/bash

clear
options='--progress --recursive --partial --inplace --preallocate --times --copy-links --delete-before -h --relative --bwlimit=2000'

rsync mirror.test.org::opensuse/distribution/13.2/iso/openSUSE-13.2-DVD* $HOME/iso/opensuse $options

rsync mirror.test.org::centos/7.0.1406/isos/x86_64/*DVD* $HOME/iso/centos $options


echo Готово

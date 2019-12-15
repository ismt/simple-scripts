#!/bin/sh

pause_sec=15

echo Убиваем сервер uwsgi
killall -2 uwsgi

echo Ждем $pause_sec секунд
sleep $pause_sec

echo Ребут
shutdown -r now

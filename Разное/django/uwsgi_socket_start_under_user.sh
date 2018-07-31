#!/bin/bash

# Старт сервера с виртуальным окружением и из под обычного юзера
# Для обновления проекта использовать опцию -u

project_dir="/var/www/nginx/route_manager_test/route_manager"
virtualenv_dir="/var/www/nginx/route_manager_test/route_manager_venv"
# Папка где лежит settings.py
app_name='route_manager'
python_version="3.6"

uid=nginx
gid=nginx

pidfile="$project_dir/tmp/uwsgi.pid"
uwsgi_log="$project_dir/logs/uwsgi.log"

if [ -f "$pidfile" ]
then
    echo '--- Завершаем uwsgi, не всегда срабатывает, проверяйте через htop'
    pid=$(cat "$pidfile")
    kill -2 "$pid"
    sleep 2
fi

cd "$project_dir"

source "$virtualenv_dir/bin/activate"

while getopts ":u" opt
do
    case "$opt" in
    u)
        git pull
        pip"$python_version" install -U -r requirements.txt
        python"$python_version" manage.py migrate

    ;;
    *) echo "No reasonable options found!";;
    esac
done

python"$python_version" manage.py collectstatic --noinput --clear > /dev/null

deactivate

# chown -R "$uid":"$gid" "$project_dir"
# chown -R "$uid":"$gid" "$virtualenv_dir"

rm -f "$uwsgi_log"

echo "--- Стартуем uwsgi"

/usr/bin/uwsgi \
    --chdir="$project_dir" \
    --module="$app_name".wsgi:application \
    --env DJANGO_SETTINGS_MODULE="$app_name".settings \
    --virtualenv="$virtualenv_dir" \
    --master \
    --pidfile="$pidfile" \
    --socket="$project_dir/tmp/uwsgi.sock" \
    --socket-timeout=600 \
    --processes=5 \
    --max-requests=5000 \
    --vacuum \
    --daemonize="$uwsgi_log" \
    --disable-logging \
    --pcre-jit \
    --enable-threads \
    --uid="$uid" \
    --gid="$gid"           \
    --touch-reload="$project_dir/application/settings_local.py"  \
    --touch-reload="$project_dir/application/settings.py"
    
echo "--- Ok"

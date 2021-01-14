#!/usr/bin/env bash

yum -y install dialog

retval=$(
    dialog --output-fd 1 \
        --title 'Настройка хоста' \
        --menu 'Выбор' 15 50 3 \
        1 'Установить пакеты' \
        2 'Старт вебсервисов'
)

case ${retval} in
1)
    yum -y erase mariadb*
    yum -y erase MariaDB*

    curl https://downloads.mariadb.com/MariaDB/mariadb_repo_setup --output /tmp/mariadb_repo_setup

    bash /tmp/mariadb_repo_setup --mariadb-server-version=mariadb-10.5

    yum -y install MariaDB-server MariaDB-shared MariaDB-devel MariaDB-rocksdb-engine MariaDB-tokudb-engine MariaDB-connect-engine

    yum -y install https://repo.manticoresearch.com/repository/manticoresearch/release/centos/8/x86_64/manticore-3.5.4_201211.13f8d08d-1.el8.x86_64.rpm

    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

    yum -y install mc wget libreoffice-calc htop iotop atop zstd zip lz4 pbzip2 p7zip lzop pv git screen unzip pigz openssh-server

    yum -y install python38 python38-pip net-tools gcc kernel-devel psmisc \
        libxml2-devel libxslt-devel nginx npm httpd-tools memcached \
        perl-DBD-MySQL smartmontools jpegoptim optipng redis hdparm fio ncdu

    # yum update -y

    echo 'Перезагрузитесь, иначе могут быть проблемы изза обновления'

    ;;

2)
    pip3.6 install pip --upgrade

    pip3.6 install uwsgi virtualenv pipenv --upgrade

    systemctl start searchd
    systemctl enable searchd

    systemctl start mariadb
    systemctl enable mariadb

    systemctl start redis
    systemctl enable redis

    ;;
esac

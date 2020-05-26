#!/usr/bin/env bash

curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bashyum update -y

yum -y install https://repo.ius.io/ius-release-el7.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install mc wget libreoffice-calc htop iotop atop zstd zip lz4 pbzip2 p7zip lzop pv git screen unzip pigz openssh-server

yum -y erase mariadb*

yum -y install MariaDB-server MariaDB-shared MariaDB-devel MariaDB-rocksdb-engine MariaDB-tokudb-engine

yum -y install python36u python36u-devel python36u-pip net-tools gcc kernel-devel psmisc libxml2-devel libxslt-devel libmemcached-devel nginx npm httpd-tools memcached mysqlreport perl-DBD-MySQL smartmontools jpegoptim optipng redis40u hdparm phoronix-test-suite fio

systemctl start mariadb
systemctl enable mariadb

pip3.6 install uwsgi virtualenv pipenv



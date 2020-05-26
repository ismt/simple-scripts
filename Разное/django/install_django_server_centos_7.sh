#!/usr/bin/env bash


yum update -y

yum -y install https://repo.ius.io/ius-release-el7.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install mc wget libreoffice-calc htop iotop atop zstd zip lz4 pbzip2 p7zip lzop pv git screen unzip pigz openssh-server

yum -y install python36u python36u-devel python36u-pip net-tools gcc kernel-devel psmisc libxml2-devel libxslt-devel libmemcached-devel nginx npm httpd-tools memcached mysqlreport perl-DBD-MySQL smartmontools jpegoptim optipng redis40u hdparm phoronix-test-suite fio


yum -y erase mariadb*

curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash

yum -y install MariaDB-server MariaDB-shared MariaDB-devel MariaDB-rocksdb-engine MariaDB-tokudb-engine

systemctl start mariadb
systemctl enable mariadb


yum  -y  install  http://sphinxsearch.com/files/sphinx-2.2.11-1.rhel7.x86_64.rpm

systemctl start searchd
systemctl enable searchd

pip3.6 install uwsgi virtualenv pipenv


systemctl start redis
systemctl enable redis
Установить CentOS 7

Установить Питон 3 из репозитория https://ius.io/GettingStarted/
```bash

yum -y install mc wget

wget https://centos7.iuscommunity.org/ius-release.rpm

yum -y install ius-release.rpm
yum -y install epel-release


yum -y erase mariadb*


yum -y install mc git htop wget python36u python36u-devel python36u-pip net-tools gcc mariadb101u-devel mariadb101u-server mariadb101u kernel-devel unzip psmisc libxml2-devel libxslt-devel libmemcached-devel nginx npm httpd-tools pigz memcached pv iotop atop  pbzip2  p7zip


yum update

#Если проблема с локалями 
#localedef -v -c -i ru_RU -f UTF-8 ru_RU.UTF-8

Подложить эталонный конфиг mariadb

systemctl start mariadb
systemctl enable mariadb


pip3.6 install uwsgi virtualenv


# https://bozza.ru/art-259.html
systemctl start firewalld
systemctl enable firewalld

# Если надо удалить сервис
# firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client

firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http

# Если надо открыть порт
# firewall-cmd --permanent --zone=public --add-port=2234/tcp

firewall-cmd --reload


systemctl restart nginx
systemctl enable nginx
```


Выполнить скрипт mysql_secure_installation


## Создать юзера под которым все будет работать
```bash
useradd server_user
passwd server_user
```


## Выключить selinux /etc/selinux/config


## Автостарт проекта
```bash
chmod 760 /etc/rc.d/rc.local

#  Добавить в файл команду старта
/usr/bin/sudo -H -u dev_stem /srv/www/dev/api/uwsgi_socket_start_simple.sh -d
```


## Виртуальное окружение

```bash
cd /srv

mkdir project_dir

cd project_dir

mkdir test

cd test

virtualenv -p /usr/bin/python3.6 virtualenv

git clone -b develop https://github.com/stemsc/.git project

```

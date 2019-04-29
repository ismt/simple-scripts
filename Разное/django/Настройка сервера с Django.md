Установить CentOS 7

Установить Питон 3 из репозитория https://ius.io/GettingStarted/
```bash

yum -y install mc wget

wget https://centos7.iuscommunity.org/ius-release.rpm

yum -y install ius-release.rpm
yum -y install epel-release


yum -y erase mariadb*


yum -y install mc git htop wget python36u python36u-devel python36u-pip net-tools gcc mariadb101u-devel mariadb101u-server mariadb101u kernel-devel unzip psmisc libxml2-devel libxslt-devel libmemcached-devel nginx npm httpd-tools pigz memcached pv iotop atop pbzip2 p7zip mysqlreport perl-DBD-MySQL smartmontools jpegoptim optipng lzop redis40u mariadb101u-server-galera

yum update  -y


# Если проблема с локалями
#localedef -v -c -i ru_RU -f UTF-8 ru_RU.UTF-8


# Подложить эталонный конфиг mariadb
systemctl start mariadb
systemctl enable mariadb

mysql_secure_installation

pip3.6 install uwsgi virtualenv pipenv

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


/etc/sysctl.conf
vm.overcommit_memory=2
vm.overcommit_ratio=90
net.core.somaxconn=65535

/etc/redis.conf
maxmemory 100M
maxmemory-policy allkeys-lru


systemctl restart redis
systemctl enable redis


```

### Если есть графика и нужно подкрутить grub - yum install grub-customizer -y

### Добавить в /etc/default/grub в опцию  GRUB_CMDLINE_LINUX_DEFAULT параметр  "scsi_mod.use_blk_mq=1" затем
```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```




### Создать юзера под которым все будет работать
```bash
useradd server_user
passwd server_user
```


### Выключить selinux /etc/selinux/config

### Автостарт проекта
```bash
chmod 760 /etc/rc.d/rc.local
```

### Добавить в /etc/rc.d/rc.local
```bash
/usr/bin/sudo -H -u dev_stem /srv/www/dev/api/uwsgi_socket_start_simple.sh -d

# В grub2 опция не работает, тогда так  или  через systemd
echo kyber > /sys/block/sda/queue/scheduler

# Для redis
echo never > /sys/kernel/mm/transparent_hugepage/enabled


```


### Виртуальное окружение

```bash
cd /srv

mkdir project_dir

cd project_dir

mkdir test

cd test

virtualenv -p /usr/bin/python3.6 virtualenv

git clone -b develop https://github.com/stemsc/.git project

```

```bash
mkfs.xfs -i size=1024 -s size=4096 -d agcount=16 /dev/sdc1

# Опции монтирования для ssd
ikeep,logbsize=256k,discard

# Опции монтирования для hdd
logbsize=256k
```



CREATE USER 'root'@'192.168.2.100' IDENTIFIED BY 'test';
GRANT ALL PRIVILEGES ON  *.* TO 'root'@'192.168.2.100';
FLUSH PRIVILEGES;
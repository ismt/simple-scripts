Установить CentOS 7

### Ссылки

##### https://github.com/major/MySQLTuner-perl/

##### Питон 3 https://ius.io/setup

##### https://downloads.mariadb.org/

Выполнить скрипт install_django_server_centos_7.sh

```bash
mysql_secure_installation

#  Затем настроить конфиг mysql

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
vm.overcommit_memory=0
vm.overcommit_ratio=90
net.core.somaxconn=65535

/etc/redis.conf
maxmemory 100M
maxmemory-policy allkeys-lru
save ""

systemctl restart redis
systemctl enable redis


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

# но у discard есть проблемы с производительностью, лучше вместо discard
systemctl enable fstrim.timer

# Опции монтирования для hdd
logbsize=256k
```





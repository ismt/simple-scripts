#!/bin/bash

sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config


yum install -y e2fsprogs-devel  keyutils-libs-devel krb5-devel libogg \
libselinux-devel libsepol-devel libxml2-devel libtiff-devel gmp php-pear \
php php-gd php-mysql php-pdo kernel-devel ncurses-devel \
mysql-connector-odbc unixODBC unixODBC-devel \
audiofile-devel libogg-devel openssl-devel zlib-devel  \
perl-DateManip sox git wget net-tools psmisc -y

yum install -y gcc-c++ make gnutls-devel kernel-devel \
libxml2-devel ncurses-devel subversion doxygen \
texinfo curl-devel net-snmp-devel neon-devel  \
uuid-devel libuuid-devel sqlite-devel sqlit  \
speex-devel gsm-devel libtool libtool-tdl libtool-ltdl-devel -y

yum install mc -y

yum update -y

yum -y install mariadb-server mariadb mariadb-devel

systemctl start mariadb.service && systemctl enable mariadb.service

mysql_secure_installation
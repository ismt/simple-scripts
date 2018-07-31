#!/bin/bash

hostname_='asuka.vst.vd'
ip_this_host='192.168.120.149'
mysql_root_pass=test
export ASTERISK_DB_PW='Glw'
operate_dir=/root/asterisk_compile
download_dir=/root/asterisk_download
export CFLAGS='-O1' # Оптимизация компилятора O2 O3
threads=2 # Количество ядер процессора

function Init {
  sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
  yum update -y
  yum install mc epel-release -y
  yum install -y e2fsprogs-devel  keyutils-libs-devel krb5-devel libogg \
      libselinux-devel libsepol-devel libxml2-devel libtiff-devel gmp php-pear php-pear-DB \
      php php-gd php-mysql php-pdo kernel-devel ncurses-devel php-posix \
      audiofile-devel libogg-devel openssl-devel mysql-devel mysql-server zlib-devel \
      perl-DateManip sox autoconf automake m4 gcc-c++ make gnutls-devel kernel-devel libxml2-devel ncurses-devel \
      subversion doxygen texinfo curl-devel net-snmp-devel neon-devel \
      uuid-devel libuuid-devel sqlite-devel sqlite git speex-devel gsm-devel \
      unixODBC unixODBC-devel mysql-connector-odbc libtool-ltdl libtool-ltdl-devel libtool libsrtp \
      libsrtp-devel jansson jansson-devel libogg libogg-devel libvorbis-devel libvorbis unzip p7zip wget
  rm -r $download_dir > /dev/null 2>&1
  mkdir -p $download_dir
  cp *.zip *.tar* *.tgz *.conf $download_dir
  cd $download_dir

  groupadd asterisk
  useradd -m asterisk -g asterisk

  sed -i s/HOSTNAME=.*/HOSTNAME=$hostname_/g /etc/sysconfig/network # -e
  echo 127.0.0.1 $hostname_ >> /etc/hosts

  echo ///////////////////////////////////////////////////////////////////////////////
  echo Перезагрузитесь, уберите закомментируйте функцию Init в скрипте и перезапустите его
  exit
}

# Таки да, здесь закомментировать
Init

#---------------------------------------------------------------------------------------------------------------------------------------
function Compile {
  #echo -----------------------------------------------------------------------------------------------------------------------------------------------
  #cd $operate_dir/srtp
  #autoconf && ./configure CFLAGS=-fPIC --prefix=/usr && make -j $threads && make runtest && make install &&
  #echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  #cd $operate_dir/jansson &&
  #./configure --prefix=/usr/ && make clean && make && make install && ldconfig &&
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/dahdi &&
  make -j $threads all && make install && make config &&
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/lame &&
  ./configure --bindir=/bin --sbindir=/usr/sbin --libdir=/usr/lib &&
  make -j $threads && make install &&
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/libpri &&
  make -j $threads && make install &&
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/pjproject &&
  ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample \
              --disable-video --disable-opencore-amr --libdir=/usr/lib --prefix=/usr &&
  make dep && make -j $threads && make install && ldconfig &&
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/asterisk &&
  ./contrib/scripts/get_mp3_source.sh
  ./configure --with-vorbis --with-ogg &&
  make menuselect && # Сохранение кнопка x // add-ons => format_mp3 , applications => app_meetme, app_confbridge
  make -j $threads && make install && make config && ldconfig &&
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/chan_sccp &&
  ./configure --bindir=/bin --sbindir=/usr/sbin --libdir=/usr/lib &&
  make -j $threads && make install &&
  echo -----------------------------------------------------------------------------------------------------------------------------------------------
  cd $operate_dir/asterisk-chan-dongle-asterisk11
  aclocal
  autoconf
  automake -a
  ./configure
  make
  make install
  cp -v ./etc/dongle.conf /etc/asterisk
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  /etc/init.d/mysqld start &&
  cd $operate_dir/freepbx &&
  mysqladmin -uroot password $mysql_root_pass && # Срабатывает только при первой конфигурации
  mysqladmin -uroot -p$mysql_root_pass create asterisk &&
  mysqladmin -uroot -p$mysql_root_pass create asteriskcdrdb &&
  mysql      -uroot -p$mysql_root_pass asterisk      < SQL/newinstall.sql &&
  mysql      -uroot -p$mysql_root_pass asteriskcdrdb < SQL/cdr_mysql_table.sql &&
  mysql      -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';" &&
  mysql      -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';" &&
  mysql      -uroot -p$mysql_root_pass --execute="flush privileges;"

  chown -R asterisk:asterisk /var/run/asterisk
  chown -R asterisk:asterisk /var/log/asterisk
  chown -R asterisk:asterisk /var/lib/php/session

  /etc/init.d/asterisk start &&
  sleep 5 &&
  ./install_amp --installdb --username=asteriskuser --password=${ASTERISK_DB_PW} --uid asterisk --gid asterisk --freepbxip=$ip_this_host &&
  amportal a ma installall &&
  amportal chown &&
  amportal restart &&
  echo Установка freepbx закончена

}

echo --------------------------------------------------------------------------------------------------

rm -R $operate_dir > /dev/null 2>&1
mkdir $operate_dir
cd $operate_dir

for i in $(find $download_dir -maxdepth 1 -name '*.tar*' -o -name '*.tgz' -type f)
do
  echo Распаковка $i
  tar -xf $i
done

for i in $(find $download_dir -maxdepth 1 -name '*.zip' -type f)
do
  echo Распаковка $i
  unzip $i > /dev/null 2>&1
done

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'asterisk-11*' -type d)
ln -s "$source_dir" $operate_dir/asterisk

source_dir=$(find $operate_dir/* -maxdepth 1 -iname 'chan*sccp*' -type d)
ln -s "$source_dir" $operate_dir/chan_sccp

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'pjproject*' -type d)
ln -s "$source_dir" $operate_dir/pjproject

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'lame*' -type d)
ln -s "$source_dir" $operate_dir/lame

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'libpri*' -type d)
ln -s "$source_dir" $operate_dir/libpri

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'dahdi-linux*' -type d)
ln -s "$source_dir" $operate_dir/dahdi

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'jansson*' -type d)
ln -s "$source_dir" $operate_dir/jansson

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'srtp*' -type d)
ln -s "$source_dir" $operate_dir/srtp

Compile

echo date.timezone = "Europe/Kiev"    >> /etc/php.ini
echo "/usr/local/sbin/amportal start" >> /etc/rc.local
echo 'noload => chan_skinny.so'       >> /etc/asterisk/modules.conf
echo 'load => res_features.so'        >> /etc/asterisk/modules.conf
echo 'load => chan_sccp.so'           >> /etc/asterisk/modules.conf
echo 'load => chan_dongle.so'         >> /etc/asterisk/modules.conf

cp -v $download_dir/httpd.conf /etc/httpd/conf/httpd.conf
echo ServerName $hostname_  >> /etc/httpd/conf/httpd.conf

chkconfig httpd on
chkconfig mysqld on
chkconfig iptables off
service iptables stop
service asterisk restart
service httpd restart

# Настройка apache /////////////////////////////////////////////////////////////////////////////////////////
# Пропишите /etc/httpd/conf/httpd.conf
# User asterisk
# Group asterisk
# AllowOverride  All
# ServerName
# /////////////////////////////////////////////////////////////////////////////////////////


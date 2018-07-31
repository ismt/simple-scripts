#!/bin/bash

step=1 # Шаги установки, после 1 шага установить 2

hostname_='asuka.vst.vd'
ip_this_host='127.0.0.1'
mysql_root_pass='ZpCFLEuAxJ'
export ASTERISK_DB_PW='GlwXC4'
operate_dir=/root/asterisk_compile
download_dir=/root/asterisk_download
libdir=/usr/lib64
export CFLAGS='-O1' # Оптимизация компилятора O2 O3
threads=$(grep -c '^processor' /proc/cpuinfo) # Количество ядер процессора, для скорости компиляции
proxy="" # http://192.168.120.29:3128

trap 'echo -e "\e[1;31mПрервано \e[0m" ; exit' 2 20

if [ "$proxy" != "" ] ;
then
  export http_proxy=$proxy
  export  ftp_proxy=$proxy
fi

function CheckError
{
  if [ "$?" != 0 ]
  then
    echo Ошибка, прервано
    exit
  fi
}

function SetHostname
{
  if [ "$(grep -i ^HOSTNAME /etc/sysconfig/network)" == "" ]
  then
    echo HOSTNAME=$1 >> /etc/sysconfig/network
    hostname $1
  else
    sed -i s/HOSTNAME=.*/HOSTNAME=$1/g /etc/sysconfig/network # -e
  fi
  echo $1		>	/etc/hostname
  #echo 127.0.0.1 $1	>>	/etc/hosts

}

function Rename
{
  if ! [ -d "$operate_dir/$2" ]
  then
    echo Переименовываем в $operate_dir/$2
    source_dir=$(find $operate_dir/* -maxdepth 1 -iname "$1" -type d)
    ln -s "$source_dir" $operate_dir/$2
    CheckError
  fi
}

if [ "$step" != 2 ]
then
  sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config
  if [ "$proxy" != "" ]
  then
    echo "proxy=$proxy" >> /etc/yum.conf
  fi

  yum update -y
  yum install -y php-pear php-pear-DB php php-gd php-mysql php-pdo php-posix php-mbstring
  yum install screen mc epel-release -y
  yum install -y e2fsprogs-devel  keyutils-libs-devel krb5-devel libogg \
      libselinux-devel libsepol-devel libxml2-devel libtiff-devel gmp \
      kernel-devel ncurses-devel audiofile-devel libogg-devel openssl-devel zlib-devel \
      perl-DateManip sox autoconf automake m4 gcc-c++ make gnutls-devel kernel-devel libxml2-devel ncurses-devel \
      doxygen texinfo curl-devel net-snmp-devel neon-devel \
      uuid-devel libuuid-devel sqlite-devel sqlite speex-devel gsm-devel \
      unixODBC unixODBC-devel mysql-connector-odbc libtool-ltdl libtool-ltdl-devel libtool libsrtp libsrtp-devel \
      jansson jansson-devel libogg libogg-devel libvorbis-devel libvorbis unzip p7zip wget \
      bzip2 mariadb mariadb-server mariadb-devel subversion net-tools tftp-server tftp

  groupadd asterisk
  useradd -m asterisk -g asterisk

  SetHostname $hostname_

  echo ///////////////////////////////////////////////////////////////////////////////
  echo Перезагрузитесь, выставьте переменную step=2 и перезапустите скрипт снова
  exit
fi

function Compile
{
  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/dahdi &&
  make -j $threads all && make install && make config
  CheckError

  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/lame &&
  ./configure --bindir=/bin --sbindir=/usr/sbin --libdir=$libdir &&
  make -j $threads && make install
  CheckError

  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/libpri &&
  make -j $threads && make install
  CheckError

  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/pjproject &&
  ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample \
              --disable-video --disable-opencore-amr --libdir=$libdir --prefix=/usr &&
  make dep && make -j $threads && make install && ldconfig
  CheckError

  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/asterisk &&
  ./contrib/scripts/get_mp3_source.sh
  ./configure --with-vorbis --with-ogg &&
  make menuselect && # Сохранение кнопка x // add-ons => format_mp3 , applications => app_meetme, app_confbridge
  make -j $threads && make install && make config && ldconfig
  CheckError

  echo ----------------------------------------------------------------------------------------------------------------------------------------------- &&
  cd $operate_dir/chan-sccp &&
  ./configure --bindir=/bin --sbindir=/usr/sbin --libdir=$libdir &&
  make -j $threads && make install
  CheckError

  echo -----------------------------------------------------------------------------------------------------------------------------------------------
  cd $operate_dir/chan-dongle
  aclocal
  autoconf
  automake -a
  ./configure --bindir=/bin --sbindir=/usr/sbin --libdir=$libdir
  make
  make install
  CheckError

  cp -v ./etc/dongle.conf /etc/asterisk

  echo -----------------------------------------------------------------------------------------------------------------------------------------------
  cp -v -f $download_dir/etc/my.cnf.d/server.cnf		/etc/my.cnf.d
  cp -v -f $download_dir/etc/odbc.ini				/etc
  cp -v    $download_dir/etc/asterisk/*				/etc/asterisk

  systemctl start mariadb &&
  cd $operate_dir/freepbx &&
  mysqladmin -uroot password $mysql_root_pass && # Срабатывает только при первой конфигурации
  mysql      -uroot -p$mysql_root_pass --execute="CREATE DATABASE asterisk      CHARACTER SET utf8 COLLATE utf8_general_ci" &&
  mysql      -uroot -p$mysql_root_pass --execute="CREATE DATABASE asteriskcdrdb CHARACTER SET utf8 COLLATE utf8_general_ci" &&
  mysql      -uroot -p$mysql_root_pass asterisk      < SQL/newinstall.sql &&
  mysql      -uroot -p$mysql_root_pass asteriskcdrdb < SQL/cdr_mysql_table.sql &&
  mysql      -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON asterisk.*      TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';" &&
  mysql      -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';" &&
  mysql      -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON *.*             TO root@127.0.0.1         IDENTIFIED BY '${mysql_root_pass}';" &&
  mysql      -uroot -p$mysql_root_pass --execute="flush privileges;"

  touch /var/log/asterisk/freepbx.log
  chown -R asterisk:asterisk /var/run/asterisk
  chown -R asterisk:asterisk /var/log/asterisk
  chown -R asterisk:asterisk /var/lib/php/session

  /etc/init.d/asterisk start
  rm -rf /var/www/html
  ./install_amp --installdb --username=asteriskuser --password=${ASTERISK_DB_PW} --uid asterisk --gid asterisk --freepbxip=$ip_this_host
  sleep 1
  amportal a ma installall
  amportal chown
  amportal a r
  amportal restart

  echo Установка freepbx закончена
}

echo --------------------------------------------------------------------------------------------------

rm -r			$download_dir > /dev/null 2>&1
mkdir -p 		$download_dir
cp *.zip *.tar* *.tgz	$download_dir
cp -R ./etc		$download_dir

rm -R 			$operate_dir > /dev/null 2>&1
mkdir 			$operate_dir
cd 			$operate_dir

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

Rename  'asterisk-13*'  asterisk
Rename  'chan*sccp*'    chan-sccp
Rename  'pjproject*'    pjproject
Rename  'lame*'         lame
Rename  'libpri*'       libpri
Rename  'dahdi-linux*'  dahdi
Rename  '*chan*dongle*' chan-dongle

Compile

echo 'export EDITOR=mcedit'		>> /root/.bashrc
echo date.timezone = "Europe/Kiev"	>> /etc/php.ini
echo "/usr/local/sbin/amportal start"	>> /etc/rc.local
echo 'noload => chan_skinny.so'		>> /etc/asterisk/modules.conf
echo 'load => res_features.so'		>> /etc/asterisk/modules.conf
echo 'load => chan_sccp.so'		>> /etc/asterisk/modules.conf
echo 'load => chan_dongle.so'		>> /etc/asterisk/modules.conf

cp -v    $download_dir/etc/httpd/conf/httpd.conf	/etc/httpd/conf/httpd.conf
echo ServerName $hostname_  		>>		/etc/httpd/conf/httpd.conf

echo

/etc/init.d/asterisk restart

systemctl enable httpd
systemctl restart httpd
CheckError

systemctl enable mariadb

systemctl disable firewalld
systemctl stop firewalld

echo Готово



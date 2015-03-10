#!/bin/bash

download=0
compile=0

download_dir=/root/asterisk_download
function Init {

  zypper -n in mc gcc gcc-c++ mariadb mariadb-tools tftp termcap ncurses-devel perl-Curses \
             libuuid-devel libjansson-devel libxml2-devel sqlite3-devel apache2 libsrtp-devel libsrtp2 \
             libopenssl-devel git apache2-mod_php5 php5-mysql php5-pear-DB php5-posix yast2-http-server autoconf automake libtool m4 \
             kernel-devel

  zypper -n update

  rm -R $download_dir
  mkdir $download_dir
  cd $download_dir
  wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz
  #wget http://sourceforge.net/projects/chan-sccp-b/files/V4/Chan_SCCP-V4.1_STABLE.tar.gz
  wget http://sourceforge.net/projects/chan-sccp-b/files/V4/Chan_SCCP-4.2.0_RC2_r5943.tar.gz
  wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
  wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-1.4-current.tar.gz
  wget http://www.pjsip.org/release/2.3/pjproject-2.3.tar.bz2
  wget http://sourceforge.net/projects/lame/files/lame/3.99/lame-3.99.5.tar.gz

  export VER_FREEPBX=12.0.21 &&
  git clone http://git.freepbx.org/scm/freepbx/framework.git freepbx &&
  cd freepbx &&
  git checkout release/${VER_FREEPBX}
}

function Compile {
  threads=2
  cd $operate_dir/lame
  ./configure --bindir=/bin --sbindir=/usr/sbin --libdir=/usr/lib
  make -j $threads && make install > $operate_dir/lame_install_log 2>&1

  cd $operate_dir/dahdi
  make -j $threads all && make install > $operate_dir/dahdi_install_log 2>&1 && make config

  cd $operate_dir/chan_sccp
  ./configure
  make -j $threads && make install > $operate_dir/chan_sccp_install_log 2>&1

  cd $operate_dir/libpri
  make -j $threads && make install > $operate_dir/libpri_install_log 2>&1

  cd $operate_dir/pjproject
  CFLAGS='-DPJ_HAS_IPV6=1' ./configure --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr &&
  make dep && make -j $threads && make install > $operate_dir/pjproject_install_log 2>&1

  cd $operate_dir/asterisk
  ./configure &&
  ./contrib/scripts/get_mp3_source.sh &&
  make menuselect # Включить    выключить app_confbridge
  make -j $threads && make install > $operate_dir/asterisk_install_log 2>&1 && make config && ldconfig
}

if [ $download == "1" ] ;
then
  Init
fi


operate_dir=/root/asterisk_compile
rm -R $operate_dir
mkdir $operate_dir
cd $operate_dir

for i in $(find $download_dir -maxdepth 1 -name '*.tar*' -type f)
do
  echo Распаковка $i
  tar -xf $i
done

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'asterisk*' -type d)
ln -s "$source_dir" $operate_dir/asterisk

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'Chan_SCCP*' -type d)
ln -s "$source_dir" $operate_dir/chan_sccp

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'pjproject*' -type d)
ln -s "$source_dir" $operate_dir/pjproject

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'lame*' -type d)
ln -s "$source_dir" $operate_dir/lame

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'libpri*' -type d)
ln -s "$source_dir" $operate_dir/libpri

source_dir=$(find $operate_dir/* -maxdepth 1 -name 'dahdi-linux*' -type d)
ln -s "$source_dir" $operate_dir/dahdi

cp -R $download_dir/freepbx $operate_dir

# ----------------------------------------------------------------------------------------------------
systemctl enable mysql
systemctl restart mysql

export ASTERISK_DB_PW='GlwXC429UMxjq+fRM'
mysql_secure_installation # Задать пароль рута test

mysql_root_pass=test
mysqladmin -u root -p$mysql_root_pass create asterisk
mysqladmin -u root -p$mysql_root_pass create asteriskcdrdb

mysql -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';"
mysql -uroot -p$mysql_root_pass --execute="GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '${ASTERISK_DB_PW}';"
mysql -uroot -p$mysql_root_pass --execute="flush privileges;"

if [ $compile == "1" ] ;
then
  Compile
fi

# ----------------------------------------------------------------------------------------------------
sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 120M/' /etc/php5/apache2/php.ini
# Настроить через Yast
#sed -i 's/^DocumentRoot.*/DocumentRoot "\/var\/www\/html"/' /etc/apache2/default-server.conf
#sed -i 's/^<Directory "\/var.*/<Directory "\/var\/www\/html>"/' /etc/apache2/default-server.conf
echo User asterisk > /etc/apache2/uid.conf
echo Group asterisk >> /etc/apache2/uid.conf
a2enmod env

useradd -m asterisk ; groupadd asterisk
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib/asterisk
chown -R asterisk. $operate_dir/freepbx

systemctl enable apache2
systemctl restart apache2

#echo noload => chan_skinny.so > modules.conf
#echo load => chan_sccp.so >> modules.conf
#echo load => res_features.so >> modules.conf

# Если здесь запнется перезапустить, чтото с правами
cd $operate_dir/freepbx
./start_asterisk start
./install_amp --installdb --username=asteriskuser --password=${ASTERISK_DB_PW} --sbin /usr/sbin --bin /bin --cleaninstall

amportal a ma download manager
amportal a ma install manager
amportal a ma installall
amportal a ma refreshsignatures
amportal a reload
amportal chown
#ln -s /var/lib/asterisk/moh /var/lib/asterisk/mohmp3

amportal start



#!/bin/bash

# http://habrahabr.ru/post/233971/

function echo_color {
  case $1 in
    green       | зелёный )                         echo -e "\e[32m$2\e[0m" ;;
    light_green | светло_зелёный | светло_зеленый ) echo -e "\e[1;32m$2\e[0m" ;;
    red         | красный )                         echo -e "\e[31m$2\e[0m" ;;
    yellow      | жёлтый )                          echo -e "\e[1;33m$2\e[0m" ;;
    light_red   | светло_красный )                  echo -e "\e[1;31m$2\e[0m" ;;
    * )                                             echo $2 ;;
  esac
}

clear
echo_color green "Введите имя пользователя"
read username
#username=user1

# Путь к корню директорий для сборки, важно
base=/home/stas/Документы/OpenVpn/Сборка

operate_dir=$base/Конфиг
ca=$operate_dir/УдостоверяющийЦентр
server=$operate_dir/server
client=$operate_dir/client

groupadd -f openvpn
useradd openvpn

rm -r $operate_dir
echo_color yellow -------------------------------------------------------------------------------------------
mkdir -p $ca
cd $ca
cp $base/master.zip $ca
unzip master.zip > /dev/null

cd $ca/easy-rsa-master/easyrsa3/
./easyrsa init-pki
echo_color yellow "Создание удостоверяющего центра CA"
echo_color light_red "Файл ca.key представляет собой приватный ключ центра CA, он секретный, и его нельзя переносить на другие узлы вашей сети."
./easyrsa build-ca nopass

echo_color light_red "Берем, чтоб генерить из старых ключей"
cp -v /home/stas/Документы/OpenVpn/Сборка/КлючиСтарогоУдостоверяющегоЦентра/ca.crt $ca/easy-rsa-master/easyrsa3/pki/
cp -v /home/stas/Документы/OpenVpn/Сборка/КлючиСтарогоУдостоверяющегоЦентра/ca.key $ca/easy-rsa-master/easyrsa3/pki/private/

echo_color yellow "Создание списка отзывов сертификатов"
./easyrsa gen-crl

mkdir -p $server
cd $server
cp ../../master.zip $server
unzip master.zip > /dev/null
mkdir -p $server/etc/openvpn

cd $server/easy-rsa-master/easyrsa3/
./easyrsa init-pki
echo_color yellow "Запрос сертификата сервера"
./easyrsa gen-req server nopass

cd $ca/easy-rsa-master/easyrsa3/ 
echo_color yellow "Импортируем запрос"
./easyrsa import-req $server/easy-rsa-master/easyrsa3/pki/reqs/server.req vpn-server
echo_color yellow "Подписываем сертификат сервера, наберите yes"
./easyrsa sign-req server vpn-server

echo_color yellow "Собираем конфиг сервера"
mkdir -p $server/etc/openvpn/ccd # каталог для конфигураций клиентов
cp -v $ca/easy-rsa-master/easyrsa3/pki/ca.crt $server/etc/openvpn
cp -v $ca/easy-rsa-master/easyrsa3/pki/crl.pem $server/etc/openvpn
cp -v $ca/easy-rsa-master/easyrsa3/pki/issued/vpn-server.crt $server/etc/openvpn/server.crt
cp -v $server/easy-rsa-master/easyrsa3/pki/private/server.key $server/etc/openvpn
cp -v $base/ДефолтныеКонфиги/openssl.conf $server/etc/openvpn
cp -v $base/ДефолтныеКонфиги/server.conf  $server/etc/openvpn

echo_color yellow "Генерация файла Диффи-Хелмана"
echo_color yellow "Используется, чтобы в случае похищения ключей исключить расшифрование трафика, записанного еще до этого похищения"
cd $server/easy-rsa-master/easyrsa3/
./easyrsa gen-dh
cp -v $server/easy-rsa-master/easyrsa3/pki/dh.pem $server/etc/openvpn

echo_color yellow "Создание статического ключа HMAC"
echo_color yellow "Служит для проверки подлинности передаваемой информации. Обеспечивает защиту от DoS-атак и флуда"
cd $server/etc/openvpn
/usr/sbin/openvpn --genkey --secret ta.key

mkdir -p $client
cd $client
cp ../../master.zip $client
unzip master.zip > /dev/null
mkdir -p $client/etc/openvpn

cd $client/easy-rsa-master/easyrsa3/
./easyrsa init-pki
echo_color yellow "Запрос сертификата клиента"
./easyrsa gen-req $username nopass

cd $ca/easy-rsa-master/easyrsa3/
echo_color yellow "Импортируем запрос"
./easyrsa import-req $client/easy-rsa-master/easyrsa3/pki/reqs/$username.req $username
echo_color yellow "Генерим сертификат клиента, наберите yes"
./easyrsa sign-req client $username

echo_color yellow "Собираем конфиг клиента"
mkdir -p $client/etc/openvpn/keys
cp -v $ca/easy-rsa-master/easyrsa3/pki/ca.crt $client/etc/openvpn/keys
cp -v $ca/easy-rsa-master/easyrsa3/pki/crl.pem $client/etc/openvpn/keys
cp -v $ca/easy-rsa-master/easyrsa3/pki/issued/$username.crt $client/etc/openvpn/keys

cp -v $client/easy-rsa-master/easyrsa3/pki/private/$username.key $client/etc/openvpn/keys
cp -v $server/etc/openvpn/ta.key $client/etc/openvpn/keys

cp -v $base/ДефолтныеКонфиги/client.conf $client/etc/openvpn/server.conf
cp -v $base/ДефолтныеКонфиги/auth.cfg $client/etc/openvpn/
sed -i s/user123\.crt.*/$username.crt/g $client/etc/openvpn/server.conf # -e
sed -i s/user123\.key.*/$username.key/g $client/etc/openvpn/server.conf # -e


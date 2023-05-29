https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-debian-11

### Сервер

Сначала настраиваем интерфейс командами

```bash
umask 077
mkdir /etc/wireguard/
chmod 0600 /etc/wireguard
wg genkey > /etc/wireguard/private.key  
touch /etc/wireguard/wg0.conf      

ip link add wg0 type wireguard 
ip addr add 10.0.0.2/24 dev wg0 
wg set wg0 private-key /etc/wireguard/private.key
wg-quick save /etc/wireguard/wg0.conf  
```      

Сохранился конфиг, теперь добавим недостающее, должно получиться типа /etc/wireguard/wg0.conf
```text
[Interface]
Address = 10.0.0.2/24
ListenPort = 60000
PrivateKey = Приватный_ключ_сервера

# Вася
[Peer]
PublicKey = Публичный_ключ_клиента
AllowedIPs = 10.0.0.1/32

# Цескаридзе
[Peer]
PublicKey = Публичный_ключ_клиента
AllowedIPs = 10.0.0.3/32

```

Открыть порт VPN
```bash
firewall-cmd --permanent --zone=internal --add-port=60000/udp
firewall-cmd --reload 
```

### Клиент
```bash
umask 077
mkdir /etc/wireguard/
chmod 0600 /etc/wireguard
wg genkey > /etc/wireguard/private.key  
touch /etc/wireguard/wg0.conf      

ip link add wg0 type wireguard 
ip addr add 10.0.0.2/24 dev wg0 
wg set wg0 private-key /etc/wireguard/private.key
wg-quick save /etc/wireguard/wg0.conf  
```      

Конфиг /etc/wireguard/wg0.conf
```text
[Interface]
Address = 10.0.0.1/24
ListenPort = 41969
PrivateKey = Приватный_ключ_клиента

[Peer]
PublicKey = Публичный_ключ_сервера
AllowedIPs = 10.0.0.2/32

# Целевой IP адрес на сервере который слушают mysql и прочие
AllowedIPs = 192.168.2.5/32

Endpoint = 200.83.190.81:60000

```

### Настройка файрвола
```bash
firewall-cmd --add-interface=wg0 --zone=internal --permanent
firewall-cmd --permanent --zone=internal --add-port=3306/tcp  
firewall-cmd --reload  #  Выяснить не виден ли 10.0.0.2 из  внешней  сети

```

### Управление сетевым интерфейсом
Поднять, положить
```bash
wg-quick down wg0  
wg-quick up wg0 

```


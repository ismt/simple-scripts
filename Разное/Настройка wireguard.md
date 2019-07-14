������
������� ����������� ��������� ���������
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

���������� ������, ������ ������� �����������, ������ ���������� ����
/etc/wireguard/wg0.conf
```text
[Interface]
Address = 10.0.0.2/24
ListenPort = 60000
PrivateKey = ���������_����_�������

# ����
[Peer]
PublicKey = ���������_����_�������
AllowedIPs = 10.0.0.1/32

# ����������
[Peer]
PublicKey = ���������_����_�������
AllowedIPs = 10.0.0.3/32

```

������� ���� VPN
```bash
firewall-cmd --permanent --zone=internal --add-port=60000/udp
firewall-cmd --feload 
```

������
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

������
```text

[Interface]
Address = 10.0.0.1/24
ListenPort = 41969
PrivateKey = ���������_����_�������

[Peer]
PublicKey = ���������_����_�������

AllowedIPs = 10.0.0.2/32

# ������� IP ����� �� ������ ������� ������� mysql � ������
AllowedIPs = 192.168.2.5/32

Endpoint = 200.83.190.81:60000

```

��������� ��������

```bash
firewall-cmd --add-interface=wg0 --zone=internal --permanent
firewall-cmd --permanent --zone=internal --add-port=3306/tcp  
firewall-cmd --reload  #  �������� �� ����� �� 10.0.0.2 ��  �������  ����

```


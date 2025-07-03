### Debian 12

```bash
apt install wireguard wireguard-tools
reboot
cd /etc/wireguard
wg genkey | tee private.key | wg pubkey > public.key 
wg genkey | tee client_private.key | wg pubkey > client_public.key 
wg genkey | tee client_private2.key | wg pubkey > client_public2.key

touch wg0.conf
chmod 600 ./*

systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

firewall-cmd --permanent --zone=public --add-service=ssh
firewall-cmd --permanent --zone=public --set-target=DROP
firewall-cmd --permanent --zone=public --add-port=30123/udp
firewall-cmd --permanent --zone=trusted --add-interface=wg0
firewall-cmd --reload
```      

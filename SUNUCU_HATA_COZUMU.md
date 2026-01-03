# 🔧 VPN Error 1 - Sunucu Tarafı Sorun Giderme Rehberi

## ❌ Hata: NEVPNErrorDomain error 1

Bu hata VPN bağlantısının kurulamadığını gösterir. Genellikle **sunucu tarafında** bir sorun vardır.

## 📋 Sunucu Tarafı Kontrol Listesi

### 1. 🌐 IKEv2 Servisi Çalışıyor mu?

#### StrongSwan için:
```bash
# Servis durumunu kontrol et
sudo systemctl status strongswan
# veya
sudo systemctl status ipsec

# Servis çalışmıyorsa başlat
sudo systemctl start strongswan
sudo systemctl enable strongswan
```

#### Libreswan için:
```bash
sudo systemctl status ipsec
sudo systemctl start ipsec
```

#### Windows Server (RRAS) için:
- Server Manager > Roles > Network Policy and Access Services
- Routing and Remote Access servisinin çalıştığından emin olun

### 2. 🔓 UDP Portları Açık mı?

IKEv2 için **UDP 500** ve **UDP 4500** portları açık olmalı:

```bash
# Portları kontrol et
sudo netstat -tulpn | grep -E ':(500|4500)'

# Firewall kurallarını kontrol et (UFW)
sudo ufw status
sudo ufw allow 500/udp
sudo ufw allow 4500/udp

# Firewall kurallarını kontrol et (iptables)
sudo iptables -L -n | grep -E '500|4500'
sudo iptables -A INPUT -p udp --dport 500 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 4500 -j ACCEPT

# AWS Security Group için:
# - Inbound Rules'da UDP 500 ve 4500 portlarını açın
# - Source: 0.0.0.0/0 (veya belirli IP aralıkları)
```

### 3. 🔐 IKEv2 Yapılandırması Kontrolü

#### StrongSwan için (`/etc/ipsec.conf`):

```conf
config setup
    charondebug="ike 2, knl 2, cfg 2"

conn ikev2-psk
    auto=add
    compress=no
    type=tunnel
    keyexchange=ikev2
    fragmentation=yes
    forceencaps=yes
    dpdaction=clear
    dpddelay=300s
    rekey=no
    left=%any
    leftid=@3.79.25.202
    leftcert=server-cert.pem
    leftsendcert=always
    leftsubnet=0.0.0.0/0
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightauth2=no
    rightsourceip=10.10.10.0/24
    rightdns=8.8.8.8,8.8.4.4
    rightsendcert=never
    eap_identity=%identity
```

#### Kullanıcı Kimlik Doğrulama (`/etc/ipsec.secrets`):

```conf
# EAP kullanıcıları için
: EAP "v7wEW8XXu4obAaqf"
vpnuser : EAP "v7wEW8XXu4obAaqf"

# veya PSK için
: PSK "pre-shared-key-here"
```

### 4. 📝 iOS IKEv2 Yapılandırması ile Uyumluluk

iOS IKEv2 için şu ayarlar gerekli:

```conf
# iOS için önemli ayarlar
ike=aes256-sha256-modp2048
esp=aes256-sha256
keyexchange=ikev2
leftauth=pubkey
rightauth=eap-mschapv2
rightauth2=no
```

### 5. 🔍 Sunucu Loglarını Kontrol Et

#### StrongSwan logları:
```bash
# Canlı log takibi
sudo tail -f /var/log/syslog | grep charon
# veya
sudo journalctl -u strongswan -f

# Son logları görüntüle
sudo journalctl -u strongswan -n 100
```

#### Libreswan logları:
```bash
sudo tail -f /var/log/secure | grep pluto
```

#### Loglarda aranacaklar:
- `IKE_SA established` - Bağlantı kuruldu mu?
- `authentication failed` - Kimlik doğrulama hatası var mı?
- `no proposal chosen` - Şifreleme algoritmaları uyumsuz mu?
- `NAT detected` - NAT sorunu var mı?

### 6. 🌍 NAT Traversal (NAT-T) Kontrolü

Eğer sunucu NAT arkasındaysa veya NAT kullanıyorsa:

```conf
# ipsec.conf'da
config setup
    nat_traversal=yes
    forceencaps=yes
```

### 7. 🔐 EAP-MSCHAPv2 Kimlik Doğrulama

iOS için EAP-MSCHAPv2 aktif olmalı:

```conf
# ipsec.conf'da
rightauth=eap-mschapv2
rightauth2=no
```

### 8. 📡 Routing ve IP Forwarding

VPN trafiğinin yönlendirilmesi için:

```bash
# IP forwarding aktif mi?
sudo sysctl net.ipv4.ip_forward
# Eğer 0 ise:
sudo sysctl -w net.ipv4.ip_forward=1

# Kalıcı hale getir
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
```

### 9. 🛡️ Firewall Kuralları (iptables)

```bash
# NAT kuralları
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE

# Forward kuralları
sudo iptables -A FORWARD -s 10.10.10.0/24 -j ACCEPT
sudo iptables -A FORWARD -d 10.10.10.0/24 -j ACCEPT
```

### 10. 🔍 Test Komutları

#### Sunucu tarafında test:
```bash
# IKEv2 bağlantısını test et
sudo ipsec statusall

# Aktif bağlantıları görüntüle
sudo ipsec status

# Yapılandırmayı test et
sudo ipsec rereadsecrets
sudo ipsec reload
```

#### İstemci tarafında test (Mac/Linux):
```bash
# UDP portlarını test et
nc -u -v 3.79.25.202 500
nc -u -v 3.79.25.202 4500

# Ping testi
ping 3.79.25.202
```

## 🔧 Yaygın Sorunlar ve Çözümleri

### Sorun 1: "no proposal chosen"
**Sebep:** Şifreleme algoritmaları uyumsuz  
**Çözüm:** Sunucu yapılandırmasında iOS ile uyumlu algoritmalar kullanın:
```conf
ike=aes256-sha256-modp2048
esp=aes256-sha256
```

### Sorun 2: "authentication failed"
**Sebep:** Kullanıcı adı/şifre yanlış veya EAP yapılandırması hatalı  
**Çözüm:** 
- `/etc/ipsec.secrets` dosyasını kontrol edin
- Kullanıcı adı ve şifrenin doğru olduğundan emin olun
- EAP-MSCHAPv2 aktif olduğundan emin olun

### Sorun 3: "NAT detected but no NAT-T"
**Sebep:** NAT-T aktif değil  
**Çözüm:** `ipsec.conf`'da `nat_traversal=yes` ve `forceencaps=yes` ekleyin

### Sorun 4: Portlar kapalı
**Sebep:** Firewall UDP 500 ve 4500 portlarını engelliyor  
**Çözüm:** Firewall kurallarını kontrol edin ve portları açın

### Sorun 5: Servis çalışmıyor
**Sebep:** IKEv2 servisi durmuş  
**Çözüm:** Servisi başlatın ve otomatik başlatmayı etkinleştirin

## 📱 iOS Tarafı Kontrolleri

1. **Ayarlar > Genel > VPN**
   - ShieldVPN profili görünüyor mu?
   - Durum ne gösteriyor?

2. **Console Logları**
   - "✅ VPN BAĞLI" mesajını görüyor musunuz?
   - VPN durumu "3" (connected) oluyor mu?

3. **Sunucu Testi**
   - Uygulamada "Sunucu Testi" butonunu kullanın
   - Portlar açık mı kontrol edin

## 🎯 Hızlı Kontrol Komutları

Sunucuda şu komutları çalıştırın:

```bash
# 1. Servis durumu
sudo systemctl status strongswan

# 2. Port kontrolü
sudo netstat -tulpn | grep -E ':(500|4500)'

# 3. Log kontrolü
sudo tail -n 50 /var/log/syslog | grep charon

# 4. IPsec durumu
sudo ipsec statusall

# 5. Firewall durumu
sudo ufw status
# veya
sudo iptables -L -n
```

## 📞 Sonraki Adımlar

1. Sunucu loglarını kontrol edin
2. Portların açık olduğundan emin olun
3. IKEv2 yapılandırmasını iOS ile uyumlu hale getirin
4. EAP-MSCHAPv2 kimlik doğrulamasının aktif olduğundan emin olun
5. Firewall kurallarını kontrol edin

Sorun devam ederse, sunucu loglarını paylaşın ve daha spesifik yardım alabilirsiniz.


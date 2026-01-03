# 🔍 Error 1 (NEVPNErrorDomain) - Domain/Sunucu Bağlantı Sorunu

## ❌ Hata: NEVPNErrorDomain error 1

Bu hata **sunucuya bağlanamama** veya **kimlik doğrulama başarısızlığı** anlamına gelir.

## 🔍 Olası Nedenler

### 1. 🌐 Sunucu Erişilebilirliği Sorunu

**Kontrol:**
```bash
# Terminal'de test edin:
ping 3.79.25.202

# UDP portlarını kontrol edin:
nc -u -v 3.79.25.202 500
nc -u -v 3.79.25.202 4500
```

**Sorun:**
- Sunucu kapalı veya erişilemiyor
- UDP 500 ve 4500 portları kapalı
- Firewall engelliyor

**Çözüm:**
- Sunucunun çalıştığından emin olun
- Firewall kurallarını kontrol edin
- AWS Security Group'da UDP 500 ve 4500 portlarını açın

### 2. 🔐 Kimlik Doğrulama Sorunu

**Kontrol:**
- Kullanıcı adı: `vpnuser` doğru mu?
- Şifre: `v7wEW8XXu4obAaqf` doğru mu?
- Sunucuda EAP-MSCHAPv2 aktif mi?

**Sorun:**
- Kullanıcı adı/şifre yanlış
- Sunucuda EAP-MSCHAPv2 yapılandırması eksik
- Sunucu loglarında "authentication failed" hatası

**Çözüm:**
- Sunucu loglarını kontrol edin
- Kullanıcı bilgilerini doğrulayın
- Sunucu yapılandırmasını kontrol edin

### 3. ⚙️ IKEv2 Yapılandırması Uyumsuzluğu

**iOS Tarafı:**
```swift
serverAddress: "3.79.25.202"
remoteIdentifier: "3.79.25.202"
localIdentifier: nil
username: "vpnuser"
authenticationMethod: .none
useExtendedAuthentication: true  // EAP-MSCHAPv2
```

**Sunucu Tarafı (StrongSwan) Kontrol:**
```conf
# /etc/ipsec.conf
rightauth=eap-mschapv2  # ✅ Olmalı
rightauth2=no           # ✅ Olmalı
```

**Sorun:**
- Sunucu yapılandırması iOS ile uyumsuz
- Remote Identifier yanlış
- Authentication method uyumsuz

**Çözüm:**
- Sunucu yapılandırmasını iOS ile uyumlu hale getirin
- Remote Identifier'ı kontrol edin

### 4. 📡 Network/DNS Sorunu

**Kontrol:**
```bash
# DNS çözümlemesi
nslookup 3.79.25.202

# Network bağlantısı
traceroute 3.79.25.202
```

**Sorun:**
- DNS çözümlemesi başarısız
- Network routing sorunu
- NAT sorunu

**Çözüm:**
- DNS ayarlarını kontrol edin
- Network bağlantısını kontrol edin

## 🛠️ Debug Adımları

### Adım 1: Console Loglarını Kontrol Edin

Uygulamayı çalıştırın ve console'da şu logları arayın:

```
📡 IKEv2 Yapılandırması:
   Server Address: 3.79.25.202
   Remote Identifier: 3.79.25.202
   Username: vpnuser
```

Eğer bunlar "nil" görünüyorsa, sunucu bilgileri yüklenmemiş demektir.

### Adım 2: Sunucu Testi Yapın

Uygulamada "Sunucu Testi" butonuna tıklayın:
- ✅ Portlar açık mı?
- ✅ Sunucu erişilebilir mi?

### Adım 3: Sunucu Loglarını Kontrol Edin

Sunucuda şu komutları çalıştırın:

```bash
# StrongSwan logları
sudo tail -f /var/log/syslog | grep charon

# Aktif bağlantıları görüntüle
sudo ipsec statusall

# Son logları görüntüle
sudo journalctl -u strongswan -n 100
```

**Aranacaklar:**
- `IKE_SA established` - Bağlantı kuruldu mu?
- `authentication failed` - Kimlik doğrulama hatası var mı?
- `no proposal chosen` - Şifreleme algoritmaları uyumsuz mu?
- `NAT detected` - NAT sorunu var mı?

### Adım 4: Yapılandırmayı Doğrulayın

Console'da şu logları kontrol edin:

```
🔍 VPN Yapılandırması Son Kontrol:
   Server Address: 3.79.25.202
   Remote ID: 3.79.25.202
   Username: vpnuser
   Password Reference: Var
   Auth Method: 0
   Extended Auth: true
```

Eğer bunlar "nil" görünüyorsa, yapılandırma kaydedilmemiş demektir.

## 📋 Sunucu Tarafı Kontrol Listesi

### ✅ IKEv2 Servisi Çalışıyor mu?
```bash
sudo systemctl status strongswan
```

### ✅ UDP Portları Açık mı?
```bash
sudo netstat -tulpn | grep -E ':(500|4500)'
```

### ✅ Firewall Kuralları Doğru mu?
```bash
sudo ufw status
# veya
sudo iptables -L -n | grep -E '500|4500'
```

### ✅ EAP-MSCHAPv2 Aktif mi?
```conf
# /etc/ipsec.conf
rightauth=eap-mschapv2
rightauth2=no
```

### ✅ Kullanıcı Tanımlı mı?
```conf
# /etc/ipsec.secrets
vpnuser : EAP "v7wEW8XXu4obAaqf"
```

## 🎯 Hızlı Çözüm

1. **Sunucu Testi:** Uygulamada "Sunucu Testi" butonuna tıklayın
2. **Sunucu Logları:** Sunucuda `sudo tail -f /var/log/syslog | grep charon` çalıştırın
3. **Port Kontrolü:** UDP 500 ve 4500 portlarının açık olduğundan emin olun
4. **Yapılandırma:** Sunucu yapılandırmasını iOS ile uyumlu hale getirin

## 📞 Sonraki Adımlar

Console loglarını ve sunucu loglarını paylaşırsanız, daha spesifik yardımcı olabilirim.


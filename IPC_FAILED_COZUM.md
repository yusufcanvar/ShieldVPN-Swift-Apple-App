# 🔧 IPC Failed Hatası Çözümü (Error 5)

## ❌ Hata: IPC failed (NEVPNErrorDomain error 5)

Bu hata **VPN capability'sinin düzgün yapılandırılmadığını** gösterir. Bu sorunu çözmeden VPN çalışmaz!

## 🚨 ÖNEMLİ: Bu Hatayı Çözmeden VPN Çalışmaz!

IPC failed hatası, iOS'un VPN yapılandırmasına erişemediğini gösterir. Bu genellikle capability veya entitlement sorunudur.

## ✅ Adım Adım Çözüm

### 1. Xcode'da Projeyi Açın
- `ShieldVPN.xcodeproj` dosyasını Xcode ile açın

### 2. Personal VPN Capability Ekleme
1. Sol panelde **"ShieldVPN"** projesine tıklayın (en üstteki mavi ikon)
2. Ortadaki sekmelerden **"Signing & Capabilities"** sekmesine gidin
3. Sol üstte **"+ Capability"** butonuna tıklayın
4. Açılan listede **"Personal VPN"** seçeneğini bulun ve tıklayın
5. Capability eklendiğinde şu görünmeli:
   - ✅ Personal VPN (eklendi)
   - ✅ `com.apple.developer.networking.vpn.api` entitlement'ı otomatik eklenecek

### 3. Entitlements Dosyasını Kontrol Edin
- Sol panelde `ShieldVPN.entitlements` dosyasını açın
- İçinde şu olmalı:
```xml
<key>com.apple.developer.networking.vpn.api</key>
<array>
    <string>allow-vpn</string>
</array>
```

### 4. Build Settings Kontrolü
1. Proje ayarlarında **"Build Settings"** sekmesine gidin
2. **"Code Signing Entitlements"** ayarını bulun
3. Değer şu olmalı: `ShieldVPN/ShieldVPN.entitlements`

### 5. Temizleme ve Yeniden Build
1. **Product** → **Clean Build Folder** (Shift+Cmd+K)
2. Xcode'u kapatın
3. Xcode'u yeniden açın
4. **Product** → **Build** (Cmd+B)

### 6. iPhone'da Uygulamayı Yeniden Yükleme
1. iPhone'da uygulamayı **tamamen silin**
2. Xcode'dan yeniden yükleyin (Cmd+R)
3. İlk çalıştırmada iOS VPN izni isteyecek → **"Allow"** butonuna tıklayın

### 7. Test Etme
1. Uygulamayı açın
2. VPN'e bağlanmayı deneyin
3. Xcode Console'da (`Cmd + Shift + Y`) IPC failed hatası görünmemeli

## ⚠️ Hala IPC Failed Hatası Alıyorsanız

### Kontrol Listesi:
- [ ] Xcode'da "Personal VPN" capability eklendi mi?
- [ ] Entitlements dosyası doğru mu?
- [ ] Code Signing Entitlements ayarı doğru mu?
- [ ] Clean Build Folder yaptınız mı?
- [ ] Xcode'u yeniden açtınız mı?
- [ ] iPhone'da uygulamayı sildiniz ve yeniden yüklediniz mi?
- [ ] İlk çalıştırmada VPN izni verdiniz mi?

### Alternatif Çözümler:

#### Çözüm 1: Xcode'u Tamamen Yeniden Başlatın
```bash
# Terminal'de çalıştırın
killall Xcode
# Sonra Xcode'u yeniden açın
```

#### Çözüm 2: DerivedData'yı Temizleyin
1. Xcode → Preferences → Locations
2. DerivedData yolunu kopyalayın
3. Terminal'de:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### Çözüm 3: Entitlements Dosyasını Manuel Kontrol Edin
`ShieldVPN.entitlements` dosyasını açın ve şu içeriğe sahip olduğundan emin olun:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.vpn.api</key>
    <array>
        <string>allow-vpn</string>
    </array>
</dict>
</plist>
```

## 🔍 Error 1 İçin Kontrol Listesi

IPC failed hatası çözüldükten sonra Error 1 alıyorsanız:

### 1. Sunucu Kontrolü
```bash
# Terminal'de test edin
ping 3.79.25.202
```

### 2. Port Kontrolü
- UDP 500 (IKE) açık mı?
- UDP 4500 (NAT-T) açık mı?

### 3. Sunucu Logları
- Sunucu tarafında bağlantı denemeleri görünüyor mu?
- Hata mesajları var mı?

### 4. VPN Yapılandırması
- Kullanıcı adı: `vpnuser`
- Şifre: `v7wEW8XXu4obAaqf`
- EAP (MSCHAPv2) sunucuda aktif mi?

## 📱 iPhone'da VPN İzni

İlk çalıştırmada iOS bir VPN yapılandırması ekleme izni isteyecek:
- **"Allow"** butonuna tıklayın
- Ayarlar > Genel > VPN'de "ShieldVPN" profili görünmeli

## 🐛 Sorun Giderme

### IPC Failed Devam Ediyorsa:
1. Xcode'da capability'yi kaldırıp yeniden ekleyin
2. Entitlements dosyasını silip yeniden oluşturun
3. iPhone'da Ayarlar > Genel > VPN'de eski VPN profillerini silin
4. Uygulamayı tamamen silip yeniden yükleyin

### Error 1 Devam Ediyorsa:
1. Sunucuya ping atarak erişilebilirliği test edin
2. Sunucu loglarını kontrol edin
3. VPN yapılandırmasını kontrol edin
4. Sunucu tarafında EAP (MSCHAPv2) aktif mi kontrol edin

## ✅ Başarı Kriterleri

IPC failed hatası çözüldüğünde:
- ✅ Xcode Console'da "IPC failed" hatası görünmemeli
- ✅ VPN yapılandırması kaydedilmeli
- ✅ VPN tüneli başlatılabilmeli

Error 1 çözüldüğünde:
- ✅ VPN bağlantısı kurulmalı
- ✅ iOS üst çubuğunda "VPN" yazısı görünmeli
- ✅ Ayarlar > Genel > VPN'de "Bağlı" durumu görünmeli


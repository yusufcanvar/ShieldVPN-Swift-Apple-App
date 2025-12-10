# VPN Kurulum Talimatları

## ⚠️ ÖNEMLİ: Xcode'da VPN Capability Ekleme

Gerçek VPN bağlantısı için Xcode'da şu adımları izleyin:

### 1. Xcode'da Projeyi Açın
- `ShieldVPN.xcodeproj` dosyasını Xcode ile açın

### 2. VPN Capability Ekleme
1. Sol panelde proje adına tıklayın (ShieldVPN)
2. "Signing & Capabilities" sekmesine gidin
3. "+ Capability" butonuna tıklayın
4. "Personal VPN" seçeneğini bulun ve ekleyin
5. Bu otomatik olarak gerekli entitlements'ı ekleyecek

### 3. Entitlements Kontrolü
- Xcode otomatik olarak `ShieldVPN.entitlements` dosyası oluşturmalı
- İçinde `com.apple.developer.networking.vpn.api` olmalı

### 4. İlk Çalıştırma
- İlk kez çalıştırdığınızda iOS bir VPN yapılandırması ekleme izni isteyecek
- "Allow" butonuna tıklayın
- Ayarlar > Genel > VPN'de yeni VPN profili görünecek

## 📱 Test Sunucuları

Uygulama şu anda 2 ücretsiz VPN sunucusu içeriyor:

1. **Japonya**: `public-vpn-144.opengw.net`
2. **Almanya**: `public-vpn-89.opengw.net`

**Not**: Bu sunucular VPNGate'in ücretsiz sunucularıdır ve her zaman aktif olmayabilir. 
Gerçek kullanım için kendi VPN sunucunuzu kullanmanız önerilir.

## 🔧 Sunucu Bilgilerini Değiştirme

`VPNGateService.swift` dosyasında sunucu bilgilerini değiştirebilirsiniz:

```swift
ServerModel(
    name: "Sunucu Adı",
    countryLong: "Ülke",
    speed: 100.0,
    ping: 100,
    load: 50,
    flag: "🇹🇷",
    serverAddress: "sunucu-ip-adresi",
    username: "kullanici-adi",
    password: "sifre",
    sharedSecret: "shared-secret"
)
```

## ⚠️ Güvenlik Notu

- Şu anda şifreler kod içinde saklanıyor (basitlik için)
- Gerçek uygulamada şifreleri Keychain'de saklamalısınız
- VPN sunucu bilgilerini güvenli bir şekilde saklayın

## 🐛 Sorun Giderme

### VPN bağlanmıyor:
1. Xcode'da VPN capability eklendiğinden emin olun
2. İlk çalıştırmada izin verdiğinizden emin olun
3. Sunucu bilgilerinin doğru olduğunu kontrol edin
4. Ayarlar > Genel > VPN'de VPN profili görünüyor mu kontrol edin

### Build hatası:
- "Personal VPN" capability eklenmemiş olabilir
- Entitlements dosyası eksik olabilir
- Xcode'u yeniden başlatmayı deneyin


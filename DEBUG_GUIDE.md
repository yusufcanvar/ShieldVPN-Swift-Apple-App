# 🔍 VPN Hatalarını Debug Etme Rehberi

## 📱 Konsol Loglarını Görüntüleme

### Yöntem 1: Xcode Console (Önerilen - En Kolay)

1. **Xcode'da projeyi açın**
2. **iPhone'unuzu Mac'e bağlayın**
3. **Xcode'da uygulamayı çalıştırın** (▶️ butonu veya `Cmd + R`)
4. **Xcode'un alt kısmındaki Console'u açın**:
   - `Cmd + Shift + Y` tuşlarına basın
   - Veya View → Debug Area → Show Debug Area
5. **Console'da tüm logları göreceksiniz**:
   - `print()` ile yazdırdığımız mesajlar
   - VPN hata mesajları
   - Detaylı hata kodları

### Yöntem 2: Terminal ile Simülatör Logları

```bash
# Simülatörde çalışıyorsa:
./view-logs.sh

# Veya manuel:
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "ShieldVPN"' --level=debug
```

### Yöntem 3: Terminal ile Fiziksel Cihaz Logları

```bash
# iPhone'unuzu Mac'e bağlayın, sonra:
idevicesyslog | grep -i shieldvpn

# Veya tüm sistem logları:
idevicesyslog
```

## 🐛 Yaygın VPN Hataları ve Çözümleri

### Hata: "VPN yüklenemedi"

**Olası Nedenler:**
1. ❌ Personal VPN capability Xcode'da eklenmemiş
2. ❌ Entitlements dosyası eksik veya yanlış
3. ❌ Code signing sorunu

**Çözüm:**
1. Xcode'da projeyi açın
2. Sol panelde "ShieldVPN" → "Signing & Capabilities"
3. "+ Capability" → "Personal VPN" ekleyin
4. Clean Build Folder (`Shift + Cmd + K`)
5. Yeniden build edin (`Cmd + B`)

### Hata: "VPN kaydedilemedi"

**Konsol Loglarında Göreceğiniz:**
```
❌ VPN kaydedilirken hata:
   Description: [hata mesajı]
   Code: [hata kodu]
   Domain: [hata domain]
```

**Hata Kodları:**
- `Code: 1` veya `Code: -1` → Capability eksik
- `Domain: com.apple.networkextension` → VPN yapılandırma hatası
- `Domain: entitlement` → Entitlement sorunu

### Hata: "Keychain'den şifreler okunamadı"

**Çözüm:**
- Keychain erişim izni verilmiş olmalı
- Info.plist'te Keychain erişimi kontrol edin

## 📋 Debug Checklist

VPN bağlanmıyorsa şunları kontrol edin:

- [ ] Xcode'da "Personal VPN" capability eklendi mi?
- [ ] `ShieldVPN.entitlements` dosyası var mı?
- [ ] Entitlements dosyasında `com.apple.developer.networking.vpn.api` var mı?
- [ ] Code signing başarılı mı? (Xcode'da kontrol edin)
- [ ] İlk çalıştırmada iOS VPN izni verildi mi?
- [ ] Xcode Console'da hata mesajları var mı?

## 🔧 Detaylı Log Kontrolü

VPNManager.swift dosyasında şu loglar yazdırılıyor:

```swift
print("❌ VPN yüklenirken hata:")
print("   Description: \(error.localizedDescription)")
print("   Code: \(nsError.code)")
print("   Domain: \(nsError.domain)")
```

Bu loglar Xcode Console'da görünecek.

## 💡 İpucu

Xcode Console'u açık tutun ve VPN bağlantısını deneyin. Hata mesajları anında görünecek!


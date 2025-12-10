# 🔧 IPC Failed Hatası Çözümü

## ❌ Hata: "IPC failed" (Code: 5, Domain: NEVPNErrorDomain)

Bu hata, VPN sistem servisiyle iletişim kurulamadığını gösterir. Genellikle **Xcode'da "Personal VPN" capability'sinin eklenmemiş olmasından** kaynaklanır.

## ✅ Çözüm Adımları

### 1. Xcode'da Personal VPN Capability Ekleme

**ÇOK ÖNEMLİ:** Entitlements dosyası var ama Xcode'da capability eklenmemiş olabilir!

1. **Xcode'u açın** ve projeyi açın
2. **Sol panelde** "ShieldVPN" projesine tıklayın (mavi ikon)
3. **Üstteki sekmelerden** "Signing & Capabilities" sekmesine gidin
4. **Sol üstteki** "+ Capability" butonuna tıklayın
5. **Arama kutusuna** "Personal VPN" yazın
6. **"Personal VPN"** seçeneğini bulun ve üzerine tıklayın
7. Şunu görmelisiniz:
   ```
   Personal VPN
   ✓ com.apple.developer.networking.vpn.api
   ```

### 2. Xcode'u Yeniden Başlatın

Capability ekledikten sonra:
- Xcode'u kapatın (`Cmd + Q`)
- Xcode'u yeniden açın
- Projeyi tekrar açın

### 3. Clean Build

1. **Product → Clean Build Folder** (`Shift + Cmd + K`)
2. **Product → Build** (`Cmd + B`)

### 4. iPhone'da Uygulamayı Yeniden Yükleyin

1. iPhone'da uygulamayı **silin** (uzun basın → sil)
2. Xcode'dan **yeniden yükleyin** (`Cmd + R`)

### 5. İlk Çalıştırmada İzin Verin

İlk kez çalıştırdığınızda iOS bir VPN izni isteyecek:
- **"Allow"** butonuna tıklayın
- Ayarlar > Genel > VPN'de VPN profili görünecek

## 🔍 Kontrol Listesi

Capability ekledikten sonra şunları kontrol edin:

- [ ] Xcode'da "Signing & Capabilities" sekmesinde "Personal VPN" görünüyor mu?
- [ ] Entitlements dosyası projeye ekli mi? (`ShieldVPN.entitlements`)
- [ ] Code signing başarılı mı? (Xcode'da sarı/yeşil işaret)
- [ ] Uygulamayı yeniden derlediniz mi?
- [ ] iPhone'da uygulamayı silip yeniden yüklediniz mi?

## ⚠️ Önemli Notlar

1. **Entitlements dosyası tek başına yeterli değil!** Xcode'da capability eklemeniz gerekiyor.
2. **Capability ekledikten sonra mutlaka yeniden build edin.**
3. **İlk çalıştırmada iOS VPN izni isteyecek** - "Allow" deyin.
4. **Eğer hala çalışmıyorsa**, iPhone'u yeniden başlatmayı deneyin.

## 🐛 Hala Çalışmıyorsa

1. Xcode Console'da (`Cmd + Shift + Y`) hata mesajlarını kontrol edin
2. iPhone'da Ayarlar > Genel > VPN'de VPN profili var mı kontrol edin
3. Xcode'da "Signing & Capabilities" → Team seçimini kontrol edin
4. Development Team'inizin VPN capability'si var mı kontrol edin

## 📞 Yardım

Eğer hala "IPC failed" hatası alıyorsanız:
- Xcode Console'daki tam hata mesajını paylaşın
- "Signing & Capabilities" ekranının ekran görüntüsünü paylaşın
- Entitlements dosyasının içeriğini kontrol edin


# 🔌 VPNGate Kullanımı - Çok Basit Rehber

## 📋 VPNGate Nedir?

VPNGate, SoftEther VPN projesi tarafından sağlanan **ücretsiz VPN sunucuları**dır. Herkes kendi sunucusunu paylaşabilir ve kullanabilir.

## 🚀 En Basit Kullanım

### 1. VPNGate Sunucu Bilgilerini Al

VPNGate sunucuları şu bilgilere sahiptir:
- **Server Address**: Sunucu IP adresi veya domain (örn: `public-vpn-144.opengw.net`)
- **Username**: Genellikle `vpn`
- **Password**: Genellikle `vpn`
- **Shared Secret**: Genellikle `vpn`

### 2. iOS'ta IPSec VPN Yapılandırması

```swift
import NetworkExtension

// 1. VPN Protokolü Oluştur
let ipsecProtocol = NEVPNProtocolIPSec()
ipsecProtocol.serverAddress = "public-vpn-144.opengw.net"
ipsecProtocol.username = "vpn"
ipsecProtocol.passwordReference = "vpn".data(using: .utf8)!
ipsecProtocol.authenticationMethod = .sharedSecret
ipsecProtocol.sharedSecretReference = "vpn".data(using: .utf8)!
ipsecProtocol.remoteIdentifier = "public-vpn-144.opengw.net"
ipsecProtocol.localIdentifier = "vpn"

// 2. VPN Manager'a Ekle
let manager = NEVPNManager.shared()
manager.protocolConfiguration = ipsecProtocol
manager.localizedDescription = "VPNGate"
manager.isEnabled = true

// 3. Kaydet ve Başlat
manager.saveToPreferences { error in
    if let error = error {
        print("Hata: \(error)")
        return
    }
    
    do {
        try manager.connection.startVPNTunnel()
        print("VPN başlatıldı!")
    } catch {
        print("Başlatma hatası: \(error)")
    }
}
```

## 📝 Tam Örnek Kod

```swift
import NetworkExtension

func connectVPNGate() {
    let manager = NEVPNManager.shared()
    
    // Mevcut yapılandırmayı yükle
    manager.loadFromPreferences { error in
        if let error = error {
            print("Yükleme hatası: \(error)")
            return
        }
        
        // Eski yapılandırmayı temizle
        manager.removeFromPreferences { _ in
            // Yeni yapılandırma oluştur
            let ipsecProtocol = NEVPNProtocolIPSec()
            ipsecProtocol.serverAddress = "public-vpn-144.opengw.net"
            ipsecProtocol.username = "vpn"
            ipsecProtocol.passwordReference = "vpn".data(using: .utf8)!
            ipsecProtocol.authenticationMethod = .sharedSecret
            ipsecProtocol.sharedSecretReference = "vpn".data(using: .utf8)!
            ipsecProtocol.remoteIdentifier = "public-vpn-144.opengw.net"
            ipsecProtocol.localIdentifier = "vpn"
            ipsecProtocol.useExtendedAuthentication = false
            
            manager.protocolConfiguration = ipsecProtocol
            manager.localizedDescription = "VPNGate"
            manager.isEnabled = true
            
            // Kaydet
            manager.saveToPreferences { error in
                if let error = error {
                    print("Kaydetme hatası: \(error)")
                    return
                }
                
                // Tekrar yükle (iOS için önemli!)
                manager.loadFromPreferences { _ in
                    // Başlat
                    do {
                        try manager.connection.startVPNTunnel()
                        print("✅ VPN başlatıldı!")
                    } catch {
                        print("❌ Başlatma hatası: \(error)")
                    }
                }
            }
        }
    }
}
```

## 🔑 Gerekli Ayarlar

### 1. Xcode'da Capability Ekleme
- Proje → Signing & Capabilities → + Capability → **Personal VPN**

### 2. Entitlements Dosyası
```xml
<key>com.apple.developer.networking.vpn.api</key>
<array>
    <string>allow-vpn</string>
</array>
```

## 🌐 VPNGate Sunucu Listesi

VPNGate sunucularını bulmak için:
1. https://www.vpngate.net/ sitesine git
2. Aktif sunucuları gör
3. Sunucu bilgilerini al:
   - **HostName**: Server Address
   - **Username**: Genellikle `vpn`
   - **Password**: Genellikle `vpn`
   - **Shared Secret**: Genellikle `vpn`

## ⚠️ Önemli Notlar

1. **VPNGate sunucuları her zaman aktif değildir**
   - Sunucular zaman zaman kapanabilir
   - Güncel sunucu listesini kontrol edin

2. **Güvenlik**
   - Ücretsiz sunucular güvenli olmayabilir
   - Hassas veriler için kendi sunucunuzu kullanın

3. **Test Sunucuları**
   - Test için kullanılabilir
   - Production için önerilmez

## 🧪 Test Etme

```swift
// Bağlantı durumunu kontrol et
let status = manager.connection.status
switch status {
case .connected:
    print("✅ Bağlı")
case .connecting:
    print("⏳ Bağlanıyor...")
case .disconnected:
    print("❌ Bağlı değil")
case .invalid:
    print("❌ Geçersiz yapılandırma")
default:
    print("❓ Bilinmeyen durum")
}
```

## 📱 Bağlantıyı Kesme

```swift
manager.connection.stopVPNTunnel()
```

## 🔍 Sorun Giderme

### Error 1: Sunucuya bağlanılamıyor
- Sunucu aktif mi kontrol edin
- İnternet bağlantınızı kontrol edin
- Sunucu bilgilerini kontrol edin

### IPC Failed: Capability eksik
- Xcode'da "Personal VPN" capability'sini ekleyin
- Uygulamayı yeniden derleyin

### SecItemCopyMatching failed: Keychain sorunu
- Keychain erişim izinlerini kontrol edin
- Uygulamayı yeniden başlatın

## 📚 Daha Fazla Bilgi

- VPNGate Resmi Site: https://www.vpngate.net/
- SoftEther VPN: https://www.softether.org/
- Apple VPN Dokümantasyonu: https://developer.apple.com/documentation/networkextension


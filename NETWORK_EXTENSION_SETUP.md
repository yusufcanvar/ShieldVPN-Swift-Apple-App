# 🔧 Network Extension Kurulumu - Sistem Seviyesi VPN

## 📋 Önemli Not

Sistem seviyesinde VPN için bir **Network Extension target** oluşturmanız gerekiyor. Bu, iOS'un üst kısmında "VPN" yazısını göstermek için gerekli.

## 🚀 Adım Adım Kurulum

### 1. Xcode'da Network Extension Target Ekleme

1. Xcode'da projeyi açın
2. Sol panelde proje adına sağ tıklayın → **"Add Target..."**
3. **"Network Extension"** seçeneğini bulun ve seçin
4. **"Packet Tunnel Provider"** template'ini seçin
5. Product Name: `ShieldVPNPacketTunnel`
6. Bundle Identifier: `com.yusufcanvar.ShieldVPN.PacketTunnel` (otomatik oluşmalı)
7. **Finish** butonuna tıklayın

### 2. PacketTunnelProvider.swift Dosyasını Düzenleme

Xcode otomatik olarak `PacketTunnelProvider.swift` dosyası oluşturur. Bu dosyayı şu şekilde düzenleyin:

```swift
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // SOCKS5 Proxy bilgilerini al
        guard let protocolConfiguration = self.protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfiguration = protocolConfiguration.providerConfiguration,
              let serverAddress = providerConfiguration["serverAddress"] as? String,
              let serverPort = providerConfiguration["serverPort"] as? Int else {
            completionHandler(NSError(domain: "PacketTunnelProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Yapılandırma bilgileri eksik"]))
            return
        }
        
        print("🚀 SOCKS5 Proxy Tunnel başlatılıyor...")
        print("   Server: \(serverAddress)")
        print("   Port: \(serverPort)")
        
        // SOCKS5 Proxy için network settings oluştur
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverAddress)
        
        // IPv4 ayarları
        let ipv4Settings = NEIPv4Settings(addresses: ["10.0.0.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4Settings
        
        // DNS ayarları
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        
        // Proxy ayarları (SOCKS5)
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpsEnabled = true
        proxySettings.excludeSimpleHostnames = false
        proxySettings.matchDomains = [""]
        
        // SOCKS5 proxy sunucusu
        proxySettings.socksServer = NEProxyServer(address: serverAddress, port: Int(serverPort))
        proxySettings.socksEnabled = true
        
        settings.proxySettings = proxySettings
        
        // Tunnel'ı başlat
        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                print("❌ Tunnel ayarları hatası: \(error.localizedDescription)")
                completionHandler(error)
            } else {
                print("✅ SOCKS5 Proxy Tunnel başlatıldı!")
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        print("🛑 SOCKS5 Proxy Tunnel durduruluyor...")
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Uygulamadan extension'a mesaj gönderme (opsiyonel)
        completionHandler?(nil)
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func wake() {
    }
}
```

### 3. Entitlements Dosyasını Kontrol Etme

Network Extension target'ı için bir entitlements dosyası oluşturulmalı. İçeriği:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.vpn.api</key>
    <array>
        <string>allow-vpn</string>
    </array>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
</dict>
</plist>
```

### 4. Info.plist Ayarları

Network Extension target'ının `Info.plist` dosyasında şu ayarlar olmalı:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.networkextension.packet-tunnel</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).PacketTunnelProvider</string>
</dict>
```

### 5. Build Settings Kontrolü

1. Network Extension target'ını seçin
2. **Build Settings** sekmesine gidin
3. **Code Signing Entitlements** ayarını kontrol edin
4. Entitlements dosyasının doğru yolu gösterildiğinden emin olun

### 6. Ana Uygulama Entitlements

Ana uygulamanın `ShieldVPN.entitlements` dosyasında şu olmalı:

```xml
<key>com.apple.developer.networking.vpn.api</key>
<array>
    <string>allow-vpn</string>
</array>
```

## ✅ Test Etme

1. Uygulamayı derleyin (`Cmd + B`)
2. iPhone'da çalıştırın
3. VPN'e bağlanmayı deneyin
4. iOS'un üst kısmında "VPN" yazısı görünmeli
5. Ayarlar > Genel > VPN'de VPN profili görünmeli

## ⚠️ Önemli Notlar

- Network Extension target'ı oluşturduktan sonra uygulamayı yeniden derlemeniz gerekir
- İlk çalıştırmada iOS VPN izni isteyecek - "Allow" butonuna tıklayın
- Network Extension target'ı ana uygulama ile aynı bundle identifier prefix'ine sahip olmalı

## 🐛 Sorun Giderme

### VPN başlatılamıyor:
- Network Extension target'ının doğru oluşturulduğundan emin olun
- Bundle identifier'ın doğru olduğunu kontrol edin (`com.yusufcanvar.ShieldVPN.PacketTunnel`)
- Entitlements dosyalarının doğru yapılandırıldığını kontrol edin

### "VPN yapılandırması geçersiz" hatası:
- Network Extension target'ının build edildiğinden emin olun
- PacketTunnelProvider.swift dosyasının doğru yapılandırıldığını kontrol edin


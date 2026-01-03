# 🧪 VPN Server Test Rehberi

Bu rehber, VPN sunucunuzun doğru çalışıp çalışmadığını test etmek için hazırlanmıştır.

## 📋 Test Araçları

Uygulama içinde iki temel test aracı bulunmaktadır:

### 1. Sunucu Testi (Server Test)
- Sunucuya erişilebilirliği kontrol eder
- UDP portlarını (500, 4500, 443) test eder
- Sunucunun aktif olup olmadığını gösterir

### 2. IP Testi (IP Change Test)
- VPN bağlantısı öncesi ve sonrası IP adresini karşılaştırır
- VPN'in çalışıp çalışmadığını doğrular

## 🚀 Kullanım

### Adım 1: Sunucu Seçin
1. Uygulamayı açın
2. Sunucu listesinden bir sunucu seçin

### Adım 2: Sunucu Testini Çalıştırın
1. "Sunucu Testi" butonuna tıklayın
2. Test sonuçları ekranda görünecektir:
   - ✅ Erişilebilir: Sunucu aktif ve erişilebilir
   - ❌ Erişilemiyor: Sunucu kapalı veya erişilemiyor

### Adım 3: VPN Bağlantısını Test Edin
1. "Bağlan" butonuna tıklayın
2. VPN bağlantısı kurulduktan sonra "IP Testi" butonuna tıklayın
3. IP değişikliği kontrol edilecektir:
   - ✅ IP Değişti: VPN çalışıyor
   - ❌ IP Değişmedi: VPN çalışmıyor olabilir

## 🔍 Test Sonuçlarını Anlama

### Sunucu Testi Sonuçları

**Başarılı Test:**
```
Test Sonuçları:
Erişilebilirlik: ✅ 2 port açık
Mevcut IP: 192.168.1.100
```

**Başarısız Test:**
```
Test Sonuçları:
Erişilebilirlik: ❌ Hiçbir port erişilebilir değil
Mevcut IP: 192.168.1.100
```

### IP Testi Sonuçları

**Başarılı Test:**
```
IP Testi: ✅ IP başarıyla değişti
```

**Başarısız Test:**
```
IP Testi: ❌ IP değişmedi
```

## 🛠️ Gelişmiş Test (Kod ile)

Eğer daha detaylı test yapmak isterseniz, `ServerConnectionTest` sınıfını kullanabilirsiniz:

```swift
import Foundation

// Sunucu erişilebilirlik testi
ServerConnectionTest.testServerReachability(serverAddress: "3.79.25.202") { success, message in
    if success {
        print("✅ Sunucu erişilebilir: \(message)")
    } else {
        print("❌ Sunucu erişilemiyor: \(message)")
    }
}

// Mevcut IP adresini al
ServerConnectionTest.getCurrentIP { ip in
    if let ip = ip {
        print("Mevcut IP: \(ip)")
    }
}

// IP değişikliği testi
ServerConnectionTest.testIPChange(beforeIP: "192.168.1.100", afterIP: "203.0.113.50") { success, message in
    if success {
        print("✅ IP değişti: \(message)")
    } else {
        print("❌ IP değişmedi: \(message)")
    }
}

// Tam test süreci
let server = ServerModel(
    name: "Test Server",
    countryLong: "Test",
    speed: 100.0,
    ping: 50,
    load: 20,
    flag: "🌐",
    serverAddress: "3.79.25.202",
    remoteIdentifier: "3.79.25.202",
    username: "vpnuser",
    password: "password"
)

ServerConnectionTest.runFullTest(server: server) { results in
    print("Test sonuçları: \(results)")
}
```

## 📝 IKEv2 Basitleştirme

IKEv2 yapılandırması basitleştirilmiştir:

### Önceki Yapı (Karmaşık)
- Keychain işlemleri için uzun delay'ler
- Gereksiz password reference güncellemeleri
- Fazla log mesajları

### Yeni Yapı (Basit)
- Direkt Keychain kullanımı
- Gereksiz delay'ler kaldırıldı
- Sadece gerekli log'lar

## ⚠️ Önemli Notlar

1. **Sunucu Testi**: Sunucu testi sadece erişilebilirliği kontrol eder, VPN bağlantısını test etmez
2. **IP Testi**: IP testi için VPN bağlantısının kurulması gerekir
3. **Port Kontrolü**: UDP portları (500, 4500) IKEv2 için kritiktir
4. **Test Sonuçları**: Test sonuçları alert olarak gösterilir

## 🐛 Sorun Giderme

### Sunucu Testi Başarısız Olursa:
1. Sunucu IP adresini kontrol edin
2. İnternet bağlantınızı kontrol edin
3. Firewall ayarlarını kontrol edin
4. Sunucunun aktif olduğundan emin olun

### IP Testi Başarısız Olursa:
1. VPN bağlantısının kurulduğundan emin olun
2. VPN durumunu kontrol edin (Ayarlar > VPN)
3. Sunucu yapılandırmasını kontrol edin
4. VPN sunucusunun proxy'nin doğru çalıştığından emin olun

## 📚 İlgili Dosyalar

- `ServerConnectionTest.swift`: Test fonksiyonları
- `VPNManager.swift`: VPN yönetimi ve test entegrasyonu
- `ContentView.swift`: Test butonları ve UI


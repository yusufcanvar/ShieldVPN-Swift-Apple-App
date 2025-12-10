//
// VPNGateTest.swift
// Başka bir projede test etmek için basit VPNGate bağlantı kodu
//

import Foundation
import NetworkExtension

class VPNGateTest {
    
    // MARK: - Basit VPNGate Bağlantısı
    
    /// VPNGate sunucusuna bağlan
    /// - Parameters:
    ///   - serverAddress: Sunucu adresi (örn: "public-vpn-144.opengw.net")
    ///   - username: Kullanıcı adı (genellikle "vpn")
    ///   - password: Şifre (genellikle "vpn")
    ///   - sharedSecret: Shared secret (genellikle "vpn")
    static func connect(
        serverAddress: String,
        username: String = "vpn",
        password: String = "vpn",
        sharedSecret: String = "vpn"
    ) {
        print("🚀 VPNGate bağlantısı başlatılıyor...")
        print("   Sunucu: \(serverAddress)")
        print("   Kullanıcı: \(username)")
        
        let manager = NEVPNManager.shared()
        
        // 1. Mevcut yapılandırmayı yükle
        manager.loadFromPreferences { error in
            if let error = error {
                print("❌ Yükleme hatası: \(error.localizedDescription)")
                return
            }
            
            // 2. Eski yapılandırmayı temizle
            manager.removeFromPreferences { removeError in
                if let removeError = removeError {
                    print("⚠️ Temizleme hatası (devam ediliyor): \(removeError.localizedDescription)")
                }
                
                // 3. Yeni VPN yapılandırması oluştur
                let ipsecProtocol = NEVPNProtocolIPSec()
                ipsecProtocol.serverAddress = serverAddress
                ipsecProtocol.username = username
                ipsecProtocol.passwordReference = password.data(using: .utf8)
                ipsecProtocol.authenticationMethod = .sharedSecret
                ipsecProtocol.sharedSecretReference = sharedSecret.data(using: .utf8)
                ipsecProtocol.remoteIdentifier = serverAddress
                ipsecProtocol.localIdentifier = username
                ipsecProtocol.useExtendedAuthentication = false
                ipsecProtocol.disconnectOnSleep = false
                
                // 4. Manager'a ekle
                manager.protocolConfiguration = ipsecProtocol
                manager.localizedDescription = "VPNGate Test"
                manager.isEnabled = true
                
                // 5. Kaydet
                manager.saveToPreferences { saveError in
                    if let saveError = saveError {
                        print("❌ Kaydetme hatası: \(saveError.localizedDescription)")
                        return
                    }
                    
                    print("✅ VPN yapılandırması kaydedildi")
                    
                    // 6. Tekrar yükle (iOS için önemli!)
                    manager.loadFromPreferences { loadError in
                        if let loadError = loadError {
                            print("⚠️ Yeniden yükleme hatası (devam ediliyor): \(loadError.localizedDescription)")
                        }
                        
                        // 7. Bağlantıyı başlat
                        do {
                            try manager.connection.startVPNTunnel()
                            print("✅ VPN bağlantısı başlatıldı!")
                            print("   Durum: \(manager.connection.status.rawValue)")
                        } catch {
                            print("❌ Başlatma hatası: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Bağlantıyı Kes
    
    static func disconnect() {
        print("🛑 VPN bağlantısı kesiliyor...")
        let manager = NEVPNManager.shared()
        manager.connection.stopVPNTunnel()
        print("✅ VPN bağlantısı kesildi")
    }
    
    // MARK: - Bağlantı Durumunu Kontrol Et
    
    static func checkStatus() {
        let manager = NEVPNManager.shared()
        let status = manager.connection.status
        
        switch status {
        case .connected:
            print("✅ VPN bağlı")
        case .connecting:
            print("⏳ VPN bağlanıyor...")
        case .disconnecting:
            print("⏳ VPN bağlantısı kesiliyor...")
        case .disconnected:
            print("❌ VPN bağlı değil")
        case .invalid:
            print("❌ VPN yapılandırması geçersiz")
        case .reasserting:
            print("🔄 VPN yeniden bağlanıyor...")
        @unknown default:
            print("❓ Bilinmeyen durum: \(status.rawValue)")
        }
    }
    
    // MARK: - Örnek Kullanım
    
    static func testExample() {
        // Örnek 1: Japonya sunucusu
        connect(
            serverAddress: "public-vpn-144.opengw.net",
            username: "vpn",
            password: "vpn",
            sharedSecret: "vpn"
        )
        
        // Örnek 2: Almanya sunucusu
        // connect(
        //     serverAddress: "public-vpn-89.opengw.net",
        //     username: "vpn",
        //     password: "vpn",
        //     sharedSecret: "vpn"
        // )
    }
}

// MARK: - Kullanım Örneği

/*
 
 // ViewController veya SwiftUI View'da kullanım:
 
 import UIKit
 import NetworkExtension
 
 class ViewController: UIViewController {
     
     @IBAction func connectButtonTapped(_ sender: UIButton) {
         VPNGateTest.connect(
             serverAddress: "public-vpn-144.opengw.net",
             username: "vpn",
             password: "vpn",
             sharedSecret: "vpn"
         )
     }
     
     @IBAction func disconnectButtonTapped(_ sender: UIButton) {
         VPNGateTest.disconnect()
     }
     
     @IBAction func checkStatusButtonTapped(_ sender: UIButton) {
         VPNGateTest.checkStatus()
     }
 }
 
 */


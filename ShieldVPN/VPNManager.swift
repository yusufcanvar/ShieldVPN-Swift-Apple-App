import SwiftUI
import NetworkExtension

class VPNManager: ObservableObject {
    @Published var state: ConnectionState = .disconnected
    @Published var selectedServer: ServerModel?
    @Published var errorMessage: String?
    
    private var vpnManager: NEVPNManager?
    
    enum ConnectionState {
        case connected
        case connecting
        case disconnecting
        case disconnected
    }
    
    init() {
        loadVPNManager()
        observeVPNStatus()
    }
    
    private func loadVPNManager() {
        NEVPNManager.shared().loadFromPreferences { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                let nsError = error as NSError
                let errorCode = nsError.code
                let errorDomain = nsError.domain
                
                if errorCode == 5 && errorDomain == "NEVPNErrorDomain" {
                    DispatchQueue.main.async {
                        self.errorMessage = "VPN Capability sorunu. Xcode'da 'Personal VPN' ekleyin."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "VPN yüklenemedi"
                    }
                }
            } else {
                self.vpnManager = NEVPNManager.shared()
                DispatchQueue.main.async {
                    self.updateConnectionState()
                }
            }
        }
    }
    
    private func observeVPNStatus() {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateConnectionState()
        }
    }
    
    private func updateConnectionState() {
        // VPN manager yüklenmeden durum güncelleme yapma
        guard vpnManager != nil else {
            return
        }
        
        let manager = NEVPNManager.shared()
        let status = manager.connection.status
        
        // Durum kodları: 0=invalid, 1=disconnected, 2=connecting, 3=connected, 4=reasserting, 5=disconnecting
        let statusNames: [Int: String] = [
            0: "invalid",
            1: "disconnected",
            2: "connecting",
            3: "connected",
            4: "reasserting",
            5: "disconnecting"
        ]
        
        switch status {
        case .connected:
            state = .connected
            errorMessage = nil
        case .connecting:
            state = .connecting
        case .disconnecting:
            state = .disconnecting
        case .disconnected:
            state = .disconnected
        case .invalid:
            state = .disconnected
            if errorMessage == nil {
                errorMessage = "VPN yapılandırması geçersiz"
            }
        case .reasserting:
            state = .connecting
        @unknown default:
            state = .disconnected
        }
    }
    
    func connect() {
        guard let server = selectedServer else {
            DispatchQueue.main.async {
                self.errorMessage = "Lütfen bir sunucu seçin"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.state = .connecting
            self.errorMessage = nil
        }
        
        // IKEv2 VPN bağlantısı
        setupIKEv2VPN(server: server)
    }
    
    func disconnect() {
        DispatchQueue.main.async {
            self.state = .disconnecting
        }
        
        if let manager = vpnManager {
            manager.connection.stopVPNTunnel()
        } else {
            NEVPNManager.shared().connection.stopVPNTunnel()
        }
    }
    
    // MARK: - Test Fonksiyonları
    
    /// Sunucu bağlantısını test et
    func testServerConnection() {
        guard let server = selectedServer else {
            DispatchQueue.main.async {
                self.errorMessage = "Lütfen bir sunucu seçin"
            }
            return
        }
        
        print("🧪 Sunucu bağlantı testi başlatılıyor...")
        ServerConnectionTest.runFullTest(server: server) { results in
            DispatchQueue.main.async {
                var message = ""
                if let reachability = results["reachability"] as? [String: Any] {
                    let success = reachability["success"] as? Bool ?? false
                    message = success ? "✅ Sunucu erişilebilir" : "❌ Sunucu erişilemiyor"
                }
                if let ip = results["currentIP"] as? String {
                    message += message.isEmpty ? "" : "\n"
                    message += "IP: \(ip)"
                }
                self.errorMessage = message.isEmpty ? "Test tamamlandı" : message
            }
        }
    }
    
    /// IP değişikliğini test et (VPN bağlantısı öncesi ve sonrası)
    func testIPChange(beforeIP: String?, afterIP: String?) {
        ServerConnectionTest.testIPChange(beforeIP: beforeIP, afterIP: afterIP) { success, message in
            // Test sonucu sadece başarısızsa göster
            if !success {
                DispatchQueue.main.async {
                    self.errorMessage = "IP Testi: \(message)"
                }
            }
        }
    }
    
    // MARK: - IKEv2 VPN Yapılandırması
    
    private func setupIKEv2VPN(server: ServerModel) {
        let manager = NEVPNManager.shared()
        
        // Apple'ın resmi tavsiyesi: loadFromPreferences -> protocolConfiguration -> saveToPreferences
        manager.loadFromPreferences { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                let nsError = error as NSError
                let errorCode = nsError.code
                let errorDomain = nsError.domain
                
                if errorCode == 5 && errorDomain == "NEVPNErrorDomain" {
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = "VPN Capability sorunu. Xcode'da 'Personal VPN' ekleyin."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = "VPN yüklenemedi"
                    }
                }
                return
            }
            
            // IKEv2 Protokol Yapılandırması oluştur
            let ikev2Protocol = NEVPNProtocolIKEv2()
            
            guard !server.serverAddress.isEmpty else {
                DispatchQueue.main.async {
                    self.state = .disconnected
                    self.errorMessage = "Sunucu adresi boş"
                }
                return
            }
            
            guard !server.remoteIdentifier.isEmpty else {
                DispatchQueue.main.async {
                    self.state = .disconnected
                    self.errorMessage = "Remote Identifier boş"
                }
                return
            }
            
            ikev2Protocol.serverAddress = server.serverAddress
            ikev2Protocol.remoteIdentifier = server.remoteIdentifier
            ikev2Protocol.localIdentifier = server.username
            ikev2Protocol.username = server.username
            
            // Password'i Keychain'e kaydet ve persistent reference al
            guard let passwordReference = KeychainHelper.shared.savePassword(
                server.password,
                account: server.username
            ) else {
                DispatchQueue.main.async {
                    self.state = .disconnected
                    self.errorMessage = "Şifre Keychain'e kaydedilemedi"
                }
                return
            }
            
            // Test: Password Reference boyutunu kontrol et (20 bytes ise invalid olur)
            print("Password Reference:", passwordReference)
            print("Password Reference size:", passwordReference.count)
            
            if passwordReference.count == 20 {
                print("⚠️ UYARI: Password Reference 20 bytes - iOS IKEv2 profili geçersiz olabilir!")
            }
            
            ikev2Protocol.passwordReference = passwordReference
            
            // IKEv2 Authentication Ayarları - EAP-MSCHAPv2 için
            ikev2Protocol.authenticationMethod = .none
            ikev2Protocol.useExtendedAuthentication = true
            ikev2Protocol.deadPeerDetectionRate = .medium
            ikev2Protocol.disableMOBIKE = false
            ikev2Protocol.disconnectOnSleep = false
            
            // Security Association Parameters
            ikev2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14
            ikev2Protocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
            ikev2Protocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256
            ikev2Protocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
            
            ikev2Protocol.childSecurityAssociationParameters.diffieHellmanGroup = .group14
            ikev2Protocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
            ikev2Protocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256
            ikev2Protocol.childSecurityAssociationParameters.lifetimeMinutes = 1440
            
            guard ikev2Protocol.passwordReference != nil else {
                DispatchQueue.main.async {
                    self.state = .disconnected
                    self.errorMessage = "VPN şifresi hazırlanamadı"
                }
                return
            }
            
            // protocolConfiguration ayarla
            manager.protocolConfiguration = ikev2Protocol
            manager.localizedDescription = "ShieldVPN"
            manager.isEnabled = true
            
            // saveToPreferences
            manager.saveToPreferences { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    let nsError = error as NSError
                    var errorMsg = "VPN kaydedilemedi"
                    if nsError.code == 5 && nsError.domain == "NEVPNErrorDomain" {
                        errorMsg = "VPN Capability sorunu. Xcode'da 'Personal VPN' ekleyin."
                    }
                    
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = errorMsg
                    }
                    return
                }
                
                // Yapılandırmayı tekrar yükle (iOS için önemli)
                manager.loadFromPreferences { [weak self] loadError in
                    guard let self = self else { return }
                    
                    guard let _ = manager.protocolConfiguration as? NEVPNProtocolIKEv2 else {
                        DispatchQueue.main.async {
                            self.state = .disconnected
                            self.errorMessage = "VPN yapılandırması geçersiz"
                        }
                        return
                    }
                    
                    // Invalid durumda başlatma yapma
                    if manager.connection.status == .invalid {
                        DispatchQueue.main.async {
                            self.state = .disconnected
                            self.errorMessage = "VPN yapılandırması geçersiz. Sunucu erişilebilirliğini kontrol edin."
                        }
                        return
                    }
                    
                    // VPN tünelini başlat
                    do {
                        try manager.connection.startVPNTunnel()
                        self.vpnManager = manager
                    } catch {
                        let nsError = error as NSError
                        var errorMsg = "VPN bağlantısı kurulamadı"
                        if nsError.code == 1 {
                            errorMsg = "Sunucuya bağlanılamıyor. Sunucu erişilebilirliğini kontrol edin."
                        }
                        
                        DispatchQueue.main.async {
                            self.state = .disconnected
                            self.errorMessage = errorMsg
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 
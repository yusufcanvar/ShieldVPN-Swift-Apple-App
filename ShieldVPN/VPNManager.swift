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
                
                print("⚠️ VPN Manager yüklenirken hata:")
                print("   Description: \(error.localizedDescription)")
                print("   Code: \(errorCode)")
                print("   Domain: \(errorDomain)")
                print("   UserInfo: \(nsError.userInfo)")
                
                // IPC failed (Error 5) için özel mesaj
                if errorCode == 5 && errorDomain == "NEVPNErrorDomain" {
                    let ipcErrorMsg = """
                    ⚠️ IPC Failed Hatası (Error 5) - KRİTİK!
                    
                    Bu hata VPN capability'sinin düzgün yapılandırılmadığını gösterir.
                    Bu sorunu çözmeden VPN çalışmaz!
                    
                    ÇÖZÜM ADIMLARI:
                    
                    1. Xcode'da Projeyi Açın
                       - ShieldVPN.xcodeproj dosyasını açın
                    
                    2. Personal VPN Capability Ekleme
                       - Sol panelde 'ShieldVPN' projesine tıklayın
                       - 'Signing & Capabilities' sekmesine gidin
                       - '+ Capability' butonuna tıklayın
                       - 'Personal VPN' seçeneğini bulun ve EKLEYİN
                    
                    3. Temizleme ve Yeniden Build
                       - Product → Clean Build Folder (Shift+Cmd+K)
                       - Xcode'u kapatıp yeniden açın
                       - Product → Build (Cmd+B)
                    
                    4. iPhone'da Uygulamayı Yeniden Yükleme
                       - iPhone'da uygulamayı TAMAMEN SİLİN
                       - Xcode'dan yeniden yükleyin (Cmd+R)
                       - İlk çalıştırmada VPN izni isteğinde 'Allow' butonuna tıklayın
                    
                    DETAYLI TALİMATLAR:
                    IPC_FAILED_COZUM.md dosyasına bakın!
                    """
                    
                    DispatchQueue.main.async {
                        self.errorMessage = ipcErrorMsg
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "VPN yüklenemedi: \(error.localizedDescription)"
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
        
        print("🔄 VPN durumu güncellendi: \(status.rawValue)")
        
        switch status {
        case .connected:
            state = .connected
            errorMessage = nil
            print("✅ VPN bağlı")
        case .connecting:
            state = .connecting
            print("⏳ VPN bağlanıyor...")
        case .disconnecting:
            state = .disconnecting
            print("⏳ VPN bağlantısı kesiliyor...")
        case .disconnected:
            state = .disconnected
            // Sadece gerçekten disconnected ise mesaj göster
            if state == .disconnected && errorMessage == nil {
                print("❌ VPN bağlı değil")
            }
        case .invalid:
            // Invalid durumunu sadece gerçekten invalid ise göster
            if manager.protocolConfiguration == nil {
                state = .disconnected
                print("❌ VPN yapılandırması geçersiz")
            } else {
                state = .disconnected
            }
        case .reasserting:
            state = .connecting
            print("🔄 VPN yeniden bağlanıyor...")
        @unknown default:
            state = .disconnected
            print("❓ Bilinmeyen VPN durumu: \(status.rawValue)")
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
    
    // MARK: - IKEv2 VPN Yapılandırması
    
    private func setupIKEv2VPN(server: ServerModel) {
        print("🔧 IKEv2 VPN yapılandırması başlatılıyor...")
        print("   Server: \(server.serverAddress)")
        print("   Remote ID: \(server.remoteIdentifier)")
        print("   Username: \(server.username)")
        
        let manager = NEVPNManager.shared()
        
        // Mevcut yapılandırmayı temizle
        manager.loadFromPreferences { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                let nsError = error as NSError
                let errorCode = nsError.code
                let errorDomain = nsError.domain
                
                print("❌ VPN yüklenirken hata:")
                print("   Description: \(error.localizedDescription)")
                print("   Code: \(errorCode)")
                print("   Domain: \(errorDomain)")
                print("   UserInfo: \(nsError.userInfo)")
                
                // IPC failed (Error 5) için özel mesaj
                if errorCode == 5 && errorDomain == "NEVPNErrorDomain" {
                    let ipcErrorMsg = """
                    ⚠️ IPC Failed Hatası (Error 5) - KRİTİK!
                    
                    Bu hata VPN capability'sinin düzgün yapılandırılmadığını gösterir.
                    Bu sorunu çözmeden VPN çalışmaz!
                    
                    ÇÖZÜM ADIMLARI:
                    
                    1. Xcode'da Projeyi Açın
                       - ShieldVPN.xcodeproj dosyasını açın
                    
                    2. Personal VPN Capability Ekleme
                       - Sol panelde 'ShieldVPN' projesine tıklayın
                       - 'Signing & Capabilities' sekmesine gidin
                       - '+ Capability' butonuna tıklayın
                       - 'Personal VPN' seçeneğini bulun ve EKLEYİN
                    
                    3. Temizleme ve Yeniden Build
                       - Product → Clean Build Folder (Shift+Cmd+K)
                       - Xcode'u kapatıp yeniden açın
                       - Product → Build (Cmd+B)
                    
                    4. iPhone'da Uygulamayı Yeniden Yükleme
                       - iPhone'da uygulamayı TAMAMEN SİLİN
                       - Xcode'dan yeniden yükleyin (Cmd+R)
                       - İlk çalıştırmada VPN izni isteğinde 'Allow' butonuna tıklayın
                    
                    DETAYLI TALİMATLAR:
                    IPC_FAILED_COZUM.md dosyasına bakın!
                    """
                    
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = ipcErrorMsg
                    }
                } else {
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = "VPN yüklenemedi: \(error.localizedDescription)"
                    }
                }
                return
            }
            
            // Eski yapılandırmayı temizle
            manager.removeFromPreferences { [weak self] removeError in
                guard let self = self else { return }
                
                if let removeError = removeError {
                    print("⚠️ Eski VPN temizlenirken hata (devam ediliyor): \(removeError.localizedDescription)")
                }
                
                // IKEv2 Protokol Yapılandırması
                let ikev2Protocol = NEVPNProtocolIKEv2()
                ikev2Protocol.serverAddress = server.serverAddress
                ikev2Protocol.remoteIdentifier = server.remoteIdentifier
                ikev2Protocol.localIdentifier = nil  // Local ID boş (sunucu gereksinimine göre)
                ikev2Protocol.username = server.username
                
                // Password'i hazırla - Keychain'e kaydetmeden önce Data olarak hazırla
                guard let passwordData = server.password.data(using: .utf8) else {
                    print("❌ Password Data'ya çevrilemedi!")
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = "Şifre hazırlanamadı"
                    }
                    return
                }
                
                // Keychain'e kaydet (VPN için) - iOS'un authorization pop-up'ını önlemek için
                let passwordKey = "\(server.serverAddress)_\(server.username)_password"
                
                // Eski kaydı temizle
                KeychainHelper.shared.delete(key: passwordKey)
                
                // Keychain'e kaydet
                let passwordSaved = KeychainHelper.shared.save(key: passwordKey, value: server.password)
                
                // Password reference'ı ayarla - iOS'un Keychain'den okuyabilmesi için
                // ÖNEMLİ: Password reference'ı direkt Data olarak kullanmak yerine,
                // iOS'un VPN yapılandırmasını kaydederken Keychain'den okuyabilmesi için
                // password reference'ı doğru şekilde ayarlamalıyız
                if passwordSaved {
                    // Keychain'den password'ü al
                    if let keychainPasswordData = KeychainHelper.shared.load(key: passwordKey) {
                        ikev2Protocol.passwordReference = keychainPasswordData
                        print("✅ Password Keychain'den okundu ve VPN'e atandı (\(keychainPasswordData.count) bytes)")
                    } else {
                        // Keychain'den okunamazsa direkt password data kullan
                        ikev2Protocol.passwordReference = passwordData
                        print("⚠️ Keychain'den okunamadı, direkt password data kullanılıyor")
                    }
                } else {
                    // Keychain'e kaydedilemezse direkt password data kullan
                    ikev2Protocol.passwordReference = passwordData
                    print("⚠️ Keychain'e kaydedilemedi, direkt password data kullanılıyor")
                }
                
                // IKEv2 Ayarları - Otomatik giriş için optimize edilmiş
                ikev2Protocol.useExtendedAuthentication = true  // EAP için gerekli
                ikev2Protocol.authenticationMethod = .none  // EAP (MSCHAPv2) için
                ikev2Protocol.deadPeerDetectionRate = .high
                ikev2Protocol.disableMOBIKE = false
                ikev2Protocol.disconnectOnSleep = false
                
                // DNS Ayarları (IKEv2 için DNS genellikle sunucudan gelir, ancak manuel ayarlanabilir)
                // Not: IKEv2 protokolünde DNS ayarları direkt property olarak yok
                // DNS ayarları VPN bağlantısı kurulduktan sonra sunucudan gelir veya Network Extension ile ayarlanır
                
                // IKE Security Association Parameters (AES256 / SHA256 / DH14)
                ikev2Protocol.ikeSecurityAssociationParameters.diffieHellmanGroup = .group14  // DH14
                ikev2Protocol.ikeSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256  // AES256
                ikev2Protocol.ikeSecurityAssociationParameters.integrityAlgorithm = .SHA256  // SHA256
                ikev2Protocol.ikeSecurityAssociationParameters.lifetimeMinutes = 1440
                
                // Child Security Association Parameters (AES256 / SHA256 / DH14)
                ikev2Protocol.childSecurityAssociationParameters.diffieHellmanGroup = .group14  // DH14
                ikev2Protocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256  // AES256
                ikev2Protocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256  // SHA256
                ikev2Protocol.childSecurityAssociationParameters.lifetimeMinutes = 1440
                
                // Password reference kontrolü
                guard ikev2Protocol.passwordReference != nil else {
                    print("❌ Password reference nil!")
                    DispatchQueue.main.async {
                        self.state = .disconnected
                        self.errorMessage = "VPN şifresi hazırlanamadı"
                    }
                    return
                }
                
                print("✅ Password reference hazır: \(ikev2Protocol.passwordReference!.count) bytes")
                
                print("📡 IKEv2 protokolü yapılandırıldı")
                print("   Server: \(ikev2Protocol.serverAddress ?? "nil")")
                print("   Remote ID: \(ikev2Protocol.remoteIdentifier ?? "nil")")
                print("   Local ID: \(ikev2Protocol.localIdentifier ?? "nil (boş)")")
                print("   Username: \(ikev2Protocol.username ?? "nil")")
                print("   DNS: 8.8.8.8, 8.8.4.4 (sunucudan gelecek)")
                print("   UseExtendedAuth: \(ikev2Protocol.useExtendedAuthentication)")
                print("   AuthMethod: \(ikev2Protocol.authenticationMethod.rawValue) (EAP-MSCHAPv2)")
                print("   DeadPeerDetectionRate: \(ikev2Protocol.deadPeerDetectionRate.rawValue)")
                print("   IKE Encryption: AES256 / SHA256 / DH14")
                print("   Child SA: AES256 / SHA256 / DH14")
                
                // VPN Manager Yapılandırması
                manager.protocolConfiguration = ikev2Protocol
                manager.localizedDescription = "ShieldVPN"
                manager.isEnabled = true
                
                print("💾 VPN yapılandırması kaydediliyor...")
                print("   Password reference: \(ikev2Protocol.passwordReference != nil ? "Var (\(ikev2Protocol.passwordReference!.count) bytes)" : "nil")")
                
                // iOS'un Keychain'i hazırlaması ve authorization pop-up'ını önlemek için kısa bir gecikme
                // ÖNEMLİ: Password reference ayarlandıktan sonra iOS'un Keychain'i hazırlaması için bekleme
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    
                    // Password reference'ı tekrar kontrol et ve gerekirse güncelle
                    // iOS'un VPN yapılandırmasını kaydederken Keychain'den okuyabilmesi için
                    if let keychainPasswordData = KeychainHelper.shared.load(key: passwordKey) {
                        ikev2Protocol.passwordReference = keychainPasswordData
                        print("✅ Password reference güncellendi (\(keychainPasswordData.count) bytes)")
                    }
                    
                    // VPN Manager yapılandırmasını güncelle (password reference değişmiş olabilir)
                    manager.protocolConfiguration = ikev2Protocol
                    
                    // Yapılandırmayı kaydet
                    manager.saveToPreferences { [weak self] error in
                        guard let self = self else { return }
                        
                        if let error = error {
                            let nsError = error as NSError
                            print("❌ VPN kaydedilirken hata:")
                            print("   Description: \(error.localizedDescription)")
                            print("   Code: \(nsError.code)")
                            print("   Domain: \(nsError.domain)")
                            
                            DispatchQueue.main.async {
                                self.state = .disconnected
                                self.errorMessage = "VPN kaydedilemedi: \(error.localizedDescription)"
                            }
                            return
                        }
                        
                        print("✅ VPN yapılandırması kaydedildi")
                        print("🔄 VPN yapılandırması yeniden yükleniyor...")
                        
                        // Yapılandırmayı tekrar yükle (iOS için önemli)
                        manager.loadFromPreferences { [weak self] loadError in
                            guard let self = self else { return }
                            
                            if let loadError = loadError {
                                print("⚠️ VPN yeniden yüklenirken hata (devam ediliyor): \(loadError.localizedDescription)")
                            }
                            
                            // VPN tünelini başlat
                            do {
                                print("🚀 VPN tüneli başlatılıyor...")
                                print("   Connection status: \(manager.connection.status.rawValue)")
                                
                                try manager.connection.startVPNTunnel()
                                self.vpnManager = manager
                                print("✅ VPN tüneli başlatıldı")
                                print("   Yeni connection status: \(manager.connection.status.rawValue)")
                            } catch {
                                let nsError = error as NSError
                                print("❌ VPN başlatılırken hata:")
                                print("   Description: \(error.localizedDescription)")
                                print("   Code: \(nsError.code)")
                                print("   Domain: \(nsError.domain)")
                                print("   UserInfo: \(nsError.userInfo)")
                                print("   Connection status: \(manager.connection.status.rawValue)")
                                
                                var errorMsg = "VPN başlatılamadı: \(error.localizedDescription)"
                                
                                // Error 1 için özel mesaj
                                if nsError.code == 1 {
                                    errorMsg = """
                                    ⚠️ VPN Bağlantı Hatası (Error 1)
                                    
                                    Bu hata genellikle şu nedenlerden kaynaklanır:
                                    
                                    1. 🌐 Sunucu erişilebilir değil
                                       - Sunucu adresini kontrol edin: \(server.serverAddress)
                                       - İnternet bağlantınızı kontrol edin
                                       - UDP 500 ve 4500 portlarının açık olduğundan emin olun
                                    
                                    2. 🔐 Kimlik doğrulama sorunu
                                       - Kullanıcı adı ve şifre doğru mu?
                                       - EAP (MSCHAPv2) sunucuda aktif mi?
                                    
                                    3. ⚙️ VPN yapılandırması
                                       - Xcode'da 'Personal VPN' capability eklendi mi?
                                       - Entitlements dosyası doğru mu?
                                    
                                    ÇÖZÜM:
                                    - Sunucuya ping atarak erişilebilirliği test edin
                                    - Sunucu loglarını kontrol edin
                                    - VPN yapılandırmasını kontrol edin
                                    """
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
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 
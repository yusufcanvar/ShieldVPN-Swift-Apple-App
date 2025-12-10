import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let service = "com.yusufcanvar.ShieldVPN"
    
    private init() {}
    
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { 
            print("❌ Keychain: String'i Data'ya çeviremedi")
            return false 
        }
        
        // Önce mevcut kaydı sil
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Yeni kaydı ekle - VPN için erişilebilirlik ayarı
        // kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly: VPN bağlantısı için en uygun
        // iOS'un VPN yapılandırmasını kaydederken Keychain'e erişebilmesi için gerekli
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly  // VPN için en uygun
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        if status != errSecSuccess {
            let errorMsg = SecCopyErrorMessageString(status, nil) as String? ?? "Bilinmeyen hata"
            print("❌ Keychain kaydetme hatası (\(key)): \(status) - \(errorMsg)")
        } else {
            print("✅ Keychain'e kaydedildi: \(key)")
        }
        
        return status == errSecSuccess
    }
    
    func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data {
                print("✅ Keychain'den okundu: \(key) (uzunluk: \(data.count) bytes)")
                return data
            } else {
                print("❌ Keychain'den okunan veri Data formatında değil")
            }
        } else {
            let errorMsg = SecCopyErrorMessageString(status, nil) as String? ?? "Bilinmeyen hata"
            print("❌ Keychain okuma hatası (\(key)): \(status) - \(errorMsg)")
            if status == -50 {
                print("   ⚠️ Error -50: Geçersiz parametre.")
                print("   Query: \(query)")
            }
        }
        
        return nil
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}


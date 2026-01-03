//
//  ServerConnectionTest.swift
//  ShieldVPN
//
//  Server bağlantı testleri için basit test sınıfı
//

import Foundation
import Network

/// Server bağlantı testleri için basit test sınıfı
class ServerConnectionTest {
    
    // MARK: - Server Erişilebilirlik Testi
    
    /// Sunucuya ping atarak erişilebilirliği test et
    /// - Parameters:
    ///   - serverAddress: Sunucu IP adresi veya domain
    ///   - completion: Test sonucu callback
    static func testServerReachability(
        serverAddress: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        print("🔍 Sunucu erişilebilirlik testi başlatılıyor...")
        print("   Server: \(serverAddress)")
        
        // VPN sunucuları için direkt UDP port kontrolü yap (HTTPS denemesi gereksiz)
        // IKEv2 için UDP 500 ve 4500 portları önemli
        testIPReachability(ip: serverAddress, completion: completion)
    }
    
    /// IP adresine port kontrolü yap
    private static func testIPReachability(
        ip: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        print("🔍 IP adresi erişilebilirlik testi: \(ip)")
        
        // IKEv2 için UDP 500 ve 4500 portları önemli
        let ports: [UInt16] = [500, 4500, 443]
        
        var successCount = 0
        let group = DispatchGroup()
        
        for port in ports {
            group.enter()
            
            let connection = NWConnection(
                host: NWEndpoint.Host(ip),
                port: NWEndpoint.Port(integerLiteral: port),
                using: .udp
            )
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("✅ Port \(port) açık")
                    successCount += 1
                    connection.cancel()
                    group.leave()
                case .failed(let error):
                    print("❌ Port \(port) kapalı: \(error.localizedDescription)")
                    connection.cancel()
                    group.leave()
                case .cancelled:
                    group.leave()
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            // Timeout
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                switch connection.state {
                case .ready, .failed:
                    // Zaten işlendi, bir şey yapma
                    break
                default:
                    print("⏱️ Port \(port) timeout")
                    connection.cancel()
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if successCount > 0 {
                completion(true, "\(successCount) port açık")
            } else {
                completion(false, "Hiçbir port erişilebilir değil")
            }
        }
    }
    
    // MARK: - IP Değişikliği Testi
    
    /// VPN bağlantısı öncesi ve sonrası IP adresini kontrol et
    /// - Parameters:
    ///   - beforeIP: VPN bağlantısı öncesi IP
    ///   - afterIP: VPN bağlantısı sonrası IP
    ///   - completion: Test sonucu callback
    static func testIPChange(
        beforeIP: String?,
        afterIP: String?,
        completion: @escaping (Bool, String) -> Void
    ) {
        guard let before = beforeIP, let after = afterIP else {
            completion(false, "IP adresleri alınamadı")
            return
        }
        
        if before != after {
            completion(true, "IP başarıyla değişti: \(before) -> \(after)")
        } else {
            completion(false, "IP değişmedi")
        }
    }
    
    // MARK: - Mevcut IP Adresini Al
    
    /// Mevcut IP adresini al
    /// - Parameter completion: IP adresi callback
    static func getCurrentIP(completion: @escaping (String?) -> Void) {
        // Basit IP kontrol servisi
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let ip = json["ip"] as? String else {
                completion(nil)
                return
            }
            
            completion(ip)
        }.resume()
    }
    
    // MARK: - Tam Test Süreci
    
    /// Sunucu için tam test süreci
    /// - Parameters:
    ///   - server: Test edilecek sunucu
    ///   - completion: Test sonuçları callback
    static func runFullTest(
        server: ServerModel,
        completion: @escaping ([String: Any]) -> Void
    ) {
        print("🧪 Tam test süreci başlatılıyor...")
        print("   Server: \(server.serverAddress)")
        
        var results: [String: Any] = [:]
        let group = DispatchGroup()
        
        // 1. Sunucu erişilebilirlik testi
        group.enter()
        testServerReachability(serverAddress: server.serverAddress) { success, message in
            results["reachability"] = ["success": success, "message": message]
            group.leave()
        }
        
        // 2. Mevcut IP adresini al
        group.enter()
        getCurrentIP { ip in
            results["currentIP"] = ip ?? "Alınamadı"
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("✅ Test tamamlandı")
            print("   Sonuçlar: \(results)")
            completion(results)
        }
    }
}


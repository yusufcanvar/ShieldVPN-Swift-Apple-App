import SwiftUI
import Foundation

class VPNGateService: ObservableObject {
    @Published var servers: [ServerModel] = []
    
    init() {
        // En basit yaklaşım: Çalışan test sunucuları
        // Not: Bu sunucular her zaman aktif olmayabilir
        // Gerçek kullanım için kendi VPN sunucunuzu kullanın
        loadSimpleServers()
    }
    
    private func loadSimpleServers() {
        // IKEv2 VPN sunucunuz
        servers = [
            ServerModel(
                name: "Benim IKEv2 VPN",
                countryLong: "AWS",
                speed: 100.0,
                ping: 50,
                load: 20,
                flag: "☁️",
                serverAddress: "3.79.25.202",
                remoteIdentifier: "3.79.25.202",
                username: "vpnuser",
                password: "v7wEW8XXu4obAaqf"
            )
        ]
    }
} 
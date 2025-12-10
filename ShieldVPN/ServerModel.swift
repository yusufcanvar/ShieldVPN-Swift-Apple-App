import SwiftUI

struct ServerModel: Identifiable {
    let id = UUID()
    let name: String
    let countryLong: String
    let speed: Double
    let ping: Int
    let load: Double
    let flag: String
    
    // IKEv2 VPN Bilgileri
    let serverAddress: String
    let remoteIdentifier: String
    let username: String
    let password: String
    
    init(
        name: String,
        countryLong: String,
        speed: Double,
        ping: Int,
        load: Double,
        flag: String,
        serverAddress: String,
        remoteIdentifier: String,
        username: String,
        password: String
    ) {
        self.name = name
        self.countryLong = countryLong
        self.speed = speed
        self.ping = ping
        self.load = load
        self.flag = flag
        self.serverAddress = serverAddress
        self.remoteIdentifier = remoteIdentifier
        self.username = username
        self.password = password
    }
} 
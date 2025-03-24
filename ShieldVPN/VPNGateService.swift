import SwiftUI

class VPNGateService: ObservableObject {
    @Published var servers: [ServerModel] = [
        ServerModel(name: "Japan VPN", countryLong: "Japan", speed: 100.0, ping: 100, load: 50, flag: "🇯🇵"),
        ServerModel(name: "USA VPN", countryLong: "United States", speed: 85.0, ping: 150, load: 65, flag: "🇺🇸"),
        ServerModel(name: "Germany VPN", countryLong: "Germany", speed: 90.0, ping: 60, load: 35, flag: "🇩🇪"),
        ServerModel(name: "Singapore VPN", countryLong: "Singapore", speed: 95.0, ping: 120, load: 55, flag: "🇸🇬")
    ]
} 
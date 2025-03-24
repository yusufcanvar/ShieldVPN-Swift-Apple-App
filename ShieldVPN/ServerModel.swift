import SwiftUI

struct ServerModel: Identifiable {
    let id = UUID()
    let name: String
    let countryLong: String
    let speed: Double
    let ping: Int
    let load: Double
    let flag: String
} 
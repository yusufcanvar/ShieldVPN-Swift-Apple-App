import Foundation

class ConnectionStats: ObservableObject {
    @Published var downloadSpeed: Double = 0
    @Published var uploadSpeed: Double = 0
    @Published var connectedTime: TimeInterval = 0
    
    var formattedDownloadSpeed: String {
        String(format: "%.1f MB/s", downloadSpeed)
    }
    
    var formattedUploadSpeed: String {
        String(format: "%.1f MB/s", uploadSpeed)
    }
    
    var formattedConnectedTime: String {
        let hours = Int(connectedTime) / 3600
        let minutes = Int(connectedTime) / 60 % 60
        let seconds = Int(connectedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func reset() {
        downloadSpeed = 0
        uploadSpeed = 0
        connectedTime = 0
    }
} 
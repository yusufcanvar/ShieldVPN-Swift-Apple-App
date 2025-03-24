import SwiftUI

class VPNManager: ObservableObject {
    @Published var state: ConnectionState = .disconnected
    @Published var selectedServer: ServerModel?
    
    enum ConnectionState {
        case connected
        case connecting
        case disconnecting
        case disconnected
    }
    
    func connect() {
        state = .connecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.state = .connected
        }
    }
    
    func disconnect() {
        state = .disconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.state = .disconnected
        }
    }
} 
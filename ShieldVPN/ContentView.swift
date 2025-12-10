//
//  ContentView.swift
//  ShieldVPN
//
//  Created by M2 on 26.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vpnGateService = VPNGateService()
    @StateObject private var vpnManager = VPNManager()
    @StateObject private var connectionStats = ConnectionStats()
    @State private var selectedServer: ServerModel?
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.15, blue: 0.25)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Bağlantı Durumu Kartı
                        ConnectionStatusCard(
                            isConnected: vpnManager.state == .connected,
                            isConnecting: vpnManager.state == .connecting,
                            selectedServer: selectedServer,
                            onToggle: handleConnectionToggle
                        )
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Bağlıysa İstatistikler
                        if vpnManager.state == .connected {
                            ConnectionStatsView(stats: connectionStats)
                                .padding(.horizontal)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        
                        // Sunucu Listesi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sunucular")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(vpnGateService.servers) { server in
                                ServerCardView(
                                    server: server,
                                    isSelected: selectedServer?.id == server.id,
                                    isConnected: vpnManager.state == .connected && selectedServer?.id == server.id
                                )
                                .onTapGesture {
                                    if vpnManager.state != .connected {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedServer = server
                                            vpnManager.selectedServer = server
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("ShieldVPN")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(vpnManager.errorMessage ?? "Bilinmeyen bir hata oluştu")
            }
            .onChange(of: vpnManager.errorMessage) { newValue in
                showError = newValue != nil
            }
        }
    }
    
    private func handleConnectionToggle() {
        guard let server = selectedServer else { return }
        
        // VPNManager'a sunucuyu set et
        vpnManager.selectedServer = server
        
        if vpnManager.state == .connected || vpnManager.state == .connecting {
            withAnimation(.spring(response: 0.4)) {
                vpnManager.disconnect()
                connectionStats.reset()
            }
        } else {
            withAnimation(.spring(response: 0.4)) {
                vpnManager.connect()
                // Bağlantı başarılı olursa istatistikleri başlat
                startSimulatedStats()
            }
        }
    }
    
    private func startSimulatedStats() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if vpnManager.state != .connected {
                timer.invalidate()
                return
            }
            
            withAnimation {
                connectionStats.connectedTime += 1
            }
        }
    }
}

// MARK: - Connection Status Card
struct ConnectionStatusCard: View {
    let isConnected: Bool
    let isConnecting: Bool
    let selectedServer: ServerModel?
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Durum İkonu
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isConnected ? 
                                [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                if isConnecting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                } else {
                    Image(systemName: isConnected ? "shield.checkered" : "shield")
                        .font(.system(size: 50))
                        .foregroundColor(isConnected ? .green : .blue)
                }
            }
            .padding(.top, 10)
            
            // Durum Metni
            VStack(spacing: 8) {
                Text(isConnecting ? "Bağlanıyor..." : (isConnected ? "Bağlı" : "Bağlı Değil"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let server = selectedServer {
                    HStack(spacing: 8) {
                        Text(server.flag)
                            .font(.title2)
                        Text(server.countryLong)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Sunucu seçin")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Bağlantı Butonu
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isConnected ? "xmark.circle.fill" : "lock.fill")
                    Text(isConnecting ? "Bağlanıyor..." : (isConnected ? "Bağlantıyı Kes" : "Bağlan"))
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: isConnected ? 
                            [Color.red, Color.red.opacity(0.8)] :
                            [Color.blue, Color.blue.opacity(0.8)]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: (isConnected ? Color.red : Color.blue).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .disabled(isConnecting || selectedServer == nil)
            .opacity(isConnecting || selectedServer == nil ? 0.6 : 1.0)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.6))
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Connection Stats View
struct ConnectionStatsView: View {
    @ObservedObject var stats: ConnectionStats
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .font(.title3)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Bağlantı Süresi")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(stats.formattedConnectedTime)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.6))
        )
    }
}

// MARK: - Server Card View
struct ServerCardView: View {
    let server: ServerModel
    let isSelected: Bool
    let isConnected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Bayrak
            Text(server.flag)
                .font(.system(size: 40))
            
            // Sunucu Bilgileri
            VStack(alignment: .leading, spacing: 6) {
                Text(server.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(server.countryLong)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    Label("\(server.ping)ms", systemImage: "speedometer")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label("\(Int(server.speed)) Mbps", systemImage: "wifi")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Durum İkonu
            VStack {
                if isConnected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.blue.opacity(0.5) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    ContentView()
}

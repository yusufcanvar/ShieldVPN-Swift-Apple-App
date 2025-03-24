//
//  ContentView.swift
//  ShieldVPN
//
//  Created by M2 on 26.12.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vpnGateService = VPNGateService()
    @State private var isConnected = false
    @State private var selectedServer: ServerModel?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vpnGateService.servers) { server in
                    ServerRowView(server: server, isSelected: selectedServer?.id == server.id)
                        .onTapGesture {
                            selectedServer = server
                        }
                }
            }
            .navigationTitle("VPN Servers")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        isConnected.toggle()
                    }) {
                        Text(isConnected ? "Disconnect" : "Connect")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isConnected ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedServer == nil)
                }
            }
        }
    }
}

struct ServerRowView: View {
    let server: ServerModel
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(server.flag)
                .font(.title)
            VStack(alignment: .leading) {
                Text(server.name)
                    .font(.headline)
                Text(server.countryLong)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}

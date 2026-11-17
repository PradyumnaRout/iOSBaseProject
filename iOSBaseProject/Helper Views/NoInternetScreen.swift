//
//  NoInternetScreen.swift
//  FreshMorning
//
//  Created by hb on 29/10/26.
//

import SwiftUI

struct NoInternetScreen: View {

    var body: some View {
        ZStack {
            // The background color stretches past the safe area to cover the whole screen
            Color(hex: "#F8F9FF")
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Image(.noInternetIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .padding(.bottom, 20)
                
                Text("No Internet Connection")
                    .font(.system(size: 26, weight: .semibold))
                
                Text("Please check your network settings and try again.")
                    .font(.system(size: 14, weight: .regular))
            }
        }
        // Prevents touches from passing through this overlay to the main content below
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
}


struct NoInternetBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color(hex: "#9D4300"))
                .padding(.all, 10)
                .background(
                    Circle()
                        .fill(Color(hex: "#9D4300").opacity(0.15))
                )
            
            VStack(alignment: .leading) {
                Text("No Internet Connection")
                    .font(.system(size: 14, weight: .semibold))
                
                MarqueeText(
                    text: "Please chheck your network settig and try again.",
                    font: .system(size: 13, weight: .regular),
                    speed: 50,
                    gap: 20,
                    pauseDuration: 1
                )
                .foregroundStyle(Color(hex: "#783200"))
                .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.all, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#FFDBCA").opacity(0.4))
        )
        .padding(.horizontal)
    }
}

#Preview {
    NoInternetBanner()
}



/// Internet connection Messages

/// Network Manager Stauts Message
func statusMessage(status: NetworkStatus) -> String {
    switch status {
    case .unknown:
        return "Checking connection..."
        
    case .connected:
        return "Connected"
        
    case .disconnected:
        return "No network connection"
        
    case .requiresConnection:
        return "Connection required"
    }
}

/// Network Manager Connection Type
func connectionName(type: NetworkConnectionType) -> String {
    switch type {
    case .wifi:
        return "Wi-Fi"
    case .cellular:
        return "Cellular"
    case .wiredEthernet:
        return "Ethernet"
    case .other:
        return "Other"
    case .none:
        return "None"
    }
}

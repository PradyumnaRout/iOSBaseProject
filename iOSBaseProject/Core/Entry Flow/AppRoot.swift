//
//  AppRoot.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import SwiftUI

struct AppRoot: View {
    @Environment(AppEntryModel.self) private var entry
    
    @Environment(NetworkReachabilityManager.self)
    private var networkManager

    var body: some View {
        ZStack {
            VStack {
                if networkManager.status != .connected {
                    NoInternetBanner()
                        .animation(.easeIn(duration: 0.25), value: networkManager.status)
                }
                
                Group {
                    switch entry.entryType {
                    case .auth:
                        SignInView()
                    case .user(let userConf):
                        MainTabView(tabs: userConf.tabs)
                            .id(userConf.id)
                    }
                }
            }
            
            /*
            if networkManager.status != .connected {
                NoInternetScreen()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                    .ignoresSafeArea()
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
             */
        }
        /*
         .animation(
             .easeInOut(duration: 0.25),
             value: networkManager.status
         )
         */
        .onChange(of: networkManager.status) { _, newStatus in
            print("AppRoot network status: \(newStatus)")
        }
    }
}

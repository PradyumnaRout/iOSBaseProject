//
//  iOSBaseProjectApp.swift
//  iOSBaseProject
//
//  Created by Pradyumna Rout on 26/09/26.
//

import SwiftUI

@main
struct iOSBaseProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    @State private var networkManager = NetworkReachabilityManager()

    var body: some Scene {
        WindowGroup {
            AppRoot()
                .environment(AppEntryModel(entryType: .auth))
                .environment(networkManager)
                .task {
                    networkManager.start()
                }
        }
    }
}

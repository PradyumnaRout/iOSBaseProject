//
//  AppRoot.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import SwiftUI

struct AppRoot: View {
    @Environment(AppEntryModel.self) private var entry
    
    var body: some View {
        switch entry.entryType {
        case .auth:
            SignInView()
        case .user(let userConf):
            MainTabView(tabs: userConf.tabs)
        }
    }
}

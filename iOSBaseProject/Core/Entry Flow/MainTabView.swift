//
//  MainTabView.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import SwiftUI

/// Main tab view container managing the root navigation and tab selection.
/// Uses strongly-typed TabKind mapping to ensure views and view models maintain structural
/// identity in SwiftUI's attribute graph and do not re-initialize on tab switches.
struct MainTabView: View {
    let tabs: [TabItem]
    @State private var selectedTab: String
    
    init(tabs: [TabItem]) {
        self.tabs = tabs
        _selectedTab = State(initialValue: tabs.first?.id ?? "")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabs) { tab in
                @Bindable var router = tab.router
                Tab(tab.title, systemImage: tab.icon, value: tab.id) {
                    NavigationStack(path: $router.path) {
                        TabRootView(kind: tab.kind)
                            .environment(router)
                            .navigationDestination(for: AnyRouter.self) { destination in
                                destination.view
                            }
                    }
                }
            }
        }
    }
}

/// Resolves the concrete View type for a given tab kind.
/// Returning strongly typed views (e.g. DashboardView) allows SwiftUI to optimize
/// state retention and view diffing, eliminating unnecessary re-initializations.
struct TabRootView: View {
    let kind: TabKind
    
    var body: some View {
        switch kind {
        case .dashboard:
            DashboardView()
        case .news:
            NewsView()
        case .programs:
            ProgramsView()
        case .profile:
            ProfileView()
        }
    }
}

//
//  AppEntryFlow.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import Foundation
import SwiftUI

enum AppEntry {
    case auth
    case user(UserTypeProtocol)
}

/// Protocol defining the contract for different user roles (e.g. Guest vs Registered).
protocol UserTypeProtocol {
    var userRole: String { get }
    var tabs: [TabItem] { get }
}

/// Represents the concrete kind of tab to display.
/// Using an enum instead of type-erased AnyView allows SwiftUI to maintain
/// structural identity and optimize view rendering/state preservation across tab switches.
enum TabKind: Hashable {
    case dashboard
    case news
    case programs
    case profile
}

/// Configuration model for individual tab items.
struct TabItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let router: Router
    let kind: TabKind
}

// MARK: - Dashboard

/// Dashboard view displaying main application features.
/// Accesses its tab router via @Environment(Router.self) and manages state lazily via @State.
struct DashboardView: View {
    @Environment(Router.self) private var router
    @State private var vm = DashboardViewModel()
    
    init() {
        print("Inside dashboard init")
    }
    
    var body: some View {
        let _ = print("Dashboard body evaluated")
        VStack(spacing: 16) {
            Image(systemName: "rectangle.grid.2x2")
                .font(.system(size: 50))
            
            Text("Dashboard")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Welcome to the Dashboard")
                .foregroundStyle(.secondary)
            
            Button {
                vm.pushToDetail(using: router)
            } label: {
                Text("Move to detail")
            }
        }
        .navigationTitle("Dashboard")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

/// ViewModel for DashboardView.
/// Decoupled from direct router dependency in init so @State initializes it once without side-effects.
@Observable
final class DashboardViewModel {
    init() {
        print("Dashboard viewmodel Init called!")
    }
    
    func pushToDetail(using router: Router) {
        router.push(DashboardDetailView())
    }
}

struct DashboardDetailView: View {
    var body: some View {
        Text("Dashboard Detail View")
            .navigationTitle("Detail")
    }
}

// MARK: - News

/// News view displaying news updates.
struct NewsView: View {
    @Environment(Router.self) private var router
    @State private var vm = NewsViewModel()
    
    init() {
        print("Inside news init")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 50))
            
            Text("News")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Latest news will appear here")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("News")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

/// ViewModel for NewsView.
@Observable
final class NewsViewModel {
    init() {
        print("News ViewModel Init called!")
    }
    
    func pushToDetail(using router: Router) {
        router.push(NewsDetailView())
    }
}

struct NewsDetailView: View {
    var body: some View {
        Text("News Detail View")
    }
}

// MARK: - Programs & Profile

struct ProgramsView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "play.rectangle")
                .font(.system(size: 50))
            
            Text("Programs")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Available programs will appear here")
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Programs")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

struct ProfileView: View {
    @Environment(Router.self) private var router
    @Environment(AppEntryModel.self) private var type
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 50))
            
            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
            
            Text("User profile information")
                .foregroundStyle(.secondary)
            
            Button("Login") {
                type.entryType = .auth
            }
            
            Button("Guest") {
                type.entryType = .user(UserRegistery.shared.getCurrentUser(type: "Guest") ?? GuestUser())
            }
            
            Button("Registered User") {
                type.entryType = .user(UserRegistery.shared.getCurrentUser(type: "Registered") ?? GuestUser())
            }
        }
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

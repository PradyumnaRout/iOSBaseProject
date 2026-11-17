//
//  ScreenLogger.swift
//  FreshMorning
//
//  Created by hb on 21/10/26.
//

import SwiftUI
import OSLog            // - Creating custom log category.

// MARK: - Screen Logger to Identify particular screen.

struct ScreenLogger: ViewModifier {
    
    let screenName: String
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "MyApp",
        category: "Screen"
    )
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                logger.debug("Screen Appeared :: \(screenName)")
            }
    }
}


// Create a function in View Extension
extension View {
    func logScreen(_ name: String) -> some View {
        modifier(ScreenLogger(screenName: name))
    }
}


// MARK: - Usage
/*
 struct HomeView: View {
     var body: some View {
         NavigationStack {
             VStack {
                 Text("Home Screen")

                 NavigationLink("Go to Profile") {
                     ProfileView()
                 }
             }
         }
         .logScreen("HomeView")
     }
 }
 
 
 struct ProfileView: View {
     var body: some View {
         Text("Profile Screen")
             .logScreen("ProfileView")
     }
 }
 
 On navigate will get -
 
 [Screen Appeared] HomeView
 [Screen Appeared] ProfileView
 */

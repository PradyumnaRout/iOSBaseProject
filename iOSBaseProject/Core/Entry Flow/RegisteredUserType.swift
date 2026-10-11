//
//  RegisteredUserType.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//


import SwiftUI

/// Tab configuration for Registered Users.
struct RegisteredUser: UserTypeProtocol {
    let id = UUID()

    var userRole: String {
        "Registered"
    }

    let tabs: [TabItem] = {
        let dashboardRouter = Router()
        let newsRouter = Router()
        let programsRouter = Router()
        let profileRouter = Router()

        return [
            TabItem(
                id: "dashboard",
                icon: "rectangle.grid.2x2",
                title: "Dashboard",
                router: dashboardRouter,
                kind: .dashboard
            ),
            TabItem(
                id: "news_paper",
                icon: "newspaper",
                title: "News",
                router: newsRouter,
                kind: .news
            ),
            TabItem(
                id: "programs",
                icon: "play.rectangle",
                title: "Programs",
                router: programsRouter,
                kind: .programs
            ),
            TabItem(
                id: "profile",
                icon: "person",
                title: "Profile",
                router: profileRouter,
                kind: .profile
            )
        ]
    }()
}

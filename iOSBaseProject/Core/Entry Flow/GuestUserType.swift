//
//  GuestUserType.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import SwiftUI

/// Tab configuration for Guest Users.
struct GuestUser: UserTypeProtocol {
    let id = UUID()

    var userRole: String {
        "Guest"
    }

    let tabs: [TabItem] = {
        let dashboardRouter = Router()
        let newsRouter = Router()
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
                id: "profile",
                icon: "person",
                title: "Profile",
                router: profileRouter,
                kind: .profile
            )
        ]
    }()
}

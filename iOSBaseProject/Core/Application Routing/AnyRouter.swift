//
//  AnyRouter.swift
//  FreshMorning
//
//  Created by Rahul Kiumar on 10/10/26.
//

import SwiftUI

struct AnyRouter: Hashable {
    
    let id = UUID()
    let view: AnyView
    
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



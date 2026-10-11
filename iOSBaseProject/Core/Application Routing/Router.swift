//
//  Router.swift
//  FreshMorning
//
//  Created by Rahul Kiumar on 10/10/26.
//

import Combine
import SwiftUI

@Observable
final class Router {
    var path: [AnyRouter] = []
    
    /// Push
    func push<V: View>(_ view: V) {
        path.append(AnyRouter(view: AnyView(view)))
    }
    
    /// Pop
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Move to Root
    func popToRoot() { path.removeAll() }
}

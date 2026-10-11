//
//  UserEntryModels.swift
//  FreshMorning
//
//  Created by hb on 08/10/26.
//

import Combine
import SwiftUI

@Observable
final class AppEntryModel {
    var entryType: AppEntry
    
    init(entryType: AppEntry) {
        self.entryType = entryType
    }
}

final class UserRegistery {
    static let shared = UserRegistery()
    private var userDictionary: [String: any UserTypeProtocol] = [:]
    
    private init() {
        registerUsers()
    }
    
    func registerUsers() {
        let guestUser = GuestUser()
        let registeredUser = RegisteredUser()
        
        userDictionary[guestUser.userRole] = guestUser
        userDictionary[registeredUser.userRole] = registeredUser
    }
    
    func getCurrentUser(type: String) -> (any UserTypeProtocol)? {
        return userDictionary[type]
    }
}

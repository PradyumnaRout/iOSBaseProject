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
    
    func switchToGuestUser() {
        entryType = .user(GuestUser())
    }
    
    func switchToActualUser() {
        entryType = .user(RegisteredUser())
    }
    
    func currentUser() -> (any UserTypeProtocol)? {
        switch entryType {
        case .user(let user):
            return user
        default:
            return nil
        }
    }
}

final class UserRegistery {
    static let shared = UserRegistery()
    
    private init() {}
    
    func getCurrentUser(type: String) -> (any UserTypeProtocol)? {
        switch type {
        case "Guest":
            return GuestUser()
        case "Registered":
            return RegisteredUser()
        default:
            return nil
        }
    }
}

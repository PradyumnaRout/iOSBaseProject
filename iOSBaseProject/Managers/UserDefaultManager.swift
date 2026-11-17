//
//  UserDefaultManager.swift
//  FreshMorning
//
//  Created by hb on 09/09/26.
//

import Foundation

final class UserDefaultManager {
    static let shared = UserDefaultManager()
    
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let savedId = "Saved_News_Id"
    }
    
    // Save
    func saveIds(_ values: Set<String>) {
        defaults.set(Array(values), forKey: Keys.savedId)
    }
    
    // Get
    func getIds() -> Set<String> {
        let values = defaults.stringArray(forKey: Keys.savedId) ?? []
        return Set(values)
    }
    
    // Add
    func add(_ value: String) {
        var values = getIds()
        values.insert(value)
        saveIds(values)
    }
    
    // Remove
    func remove(_ id: String) {
        var values = getIds()
        values.remove(id)
        saveIds(values)
    }
    
    // Remove All
    func removeAll() {
        defaults.removeObject(forKey: Keys.savedId)
    }
    
    
}

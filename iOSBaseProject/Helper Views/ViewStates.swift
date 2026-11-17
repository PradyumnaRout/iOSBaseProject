//
//  ViewStates.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 16/11/26.
//

import Foundation

enum ViewStates<Data> {
    case loading
    case loaded(Data)
    case empty
    case failed(String)
    
    var data: Data? {
        if case .loaded(let data) = self {
            return data
        }
        
        return nil
    }
    
    mutating func append(data: Data) where Data: RangeReplaceableCollection {
        switch self {
        case .loaded(var existingItems):
            existingItems.append(contentsOf: data)
            self = .loaded(existingItems)
        default:
            self = .loaded(data)
        }
    }
}



//
//  HTTPMethods.swift
//  iOSBaseProject
//
//  Created by Pradyumna Rout on 30/09/26.
//

import Foundation

/// http Methods
struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    
    let rawValue: String
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    static let get = HTTPMethod(rawValue: "GET")
    static let post = HTTPMethod(rawValue: "POST")
    static let put = HTTPMethod(rawValue: "PUT")
    static let patch = HTTPMethod(rawValue: "PATCH")
    static let delete = HTTPMethod(rawValue: "DELETE")
    static let query = HTTPMethod(rawValue: "QUERY")
}


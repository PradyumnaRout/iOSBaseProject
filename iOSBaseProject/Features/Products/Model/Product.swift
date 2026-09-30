//
//  Product.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let images: [String]
    let category: Category?
    
    struct Category: Codable {
        let id: Int
        let name: String
        let image: String?
    }
}

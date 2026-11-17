//
//  Product.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

struct Product: Codable, Identifiable, Hashable, Equatable {
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    let price: Double
    let slug: String
    let description: String
    let images: [String]
    let category: Category?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
         case slug = "slug"
        case price = "price"
        case description = "description"
        case category = "category"
        case images = "images"
    }
}


 nonisolated struct Category: Codable, Hashable {
     let id: Int
     let name: String
     let image: String
     let slug: String
 }

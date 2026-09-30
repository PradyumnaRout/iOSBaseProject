//
//  ProductRouter.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

enum ProductRouter: RouterProtocol {
    // Router Cases
    case products(Int, Int)
    
    var path: String {
        switch self {
        case .products:
            return "products"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .products:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .products(let offset, let limit):
            return [
                "offset": offset as Int,
                "limit": limit as Int
            ]
        }
    }
    
    var header: [String : String]? {
        [
            "Content-Type" : "application/json"
        ]
    }
    
    var deviceInfo: [String : Any]? {
        nil
    }
    
    /// Directly create from Parameter
    var queryItems: [URLQueryItem]? {
        guard let parameters else { return nil }
        
        return parameters.map { key, values in
            URLQueryItem(name: key, value: String(describing: values))
        }
    }
    
    // Create Body directly from Swift Encodable Types
    var bodyDataCodable: Data? {
        get throws {
            switch self {
            // Example usage when adding a case with Encodable payload:
            // case .createProduct(let product):
            //     do {
            //         return try JSONEncoder().encode(product)
            //     } catch {
            //         throw NetworkError.decodingFailed
            //     }
            default:
                return nil
            }
        }
    }
    
    var bodyDataSerializable: Data? {
        get throws {
            return nil
        }
    }
    
    var files: [MultiPartData]? {
        nil
    }
}

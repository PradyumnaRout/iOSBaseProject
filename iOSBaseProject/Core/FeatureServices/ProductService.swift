//
//  ProductService.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 16/11/26.
//

import Foundation

/// `Product Service Protocol`
///
protocol ProductService {
    func getproducts(with router: RouterProtocol) async throws -> [Product]
}


///  `Production Product Service`
///
class ProductionProductService: ProductService {
    
    let nwService: NetworkService
    
    init(nwService: NetworkService) {
        self.nwService = nwService
    }
    
    func getproducts(with router: any RouterProtocol) async throws -> [Product] {
        return try await nwService.dataRequest(with: router)
    }
    
}


/// `Test Product Service`
///
class TestProductService: ProductService {
    
    var throwError: Bool = false
    var products: [Product] = []
    
    func getproducts(with router: any RouterProtocol) async throws -> [Product] {
        if throwError {
            throw AppError.network(.others("Something Went Wrong!"))
        }
        
        return products
    }
}

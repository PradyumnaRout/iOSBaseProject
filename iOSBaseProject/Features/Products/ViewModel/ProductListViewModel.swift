//
//  ProductListViewModel.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation
import Combine


// MARK: MODIFY THIS TO DEPENDECNY INJECTION PATTERN USING A PRODUCT SERVICE REPOSITOY FOR API CALL INSTEAD OF DIRECLTY USING NETWORKPROTOCOL RIGHT HERE. AND ALSO CREATE SCREEN STATE PUBLIC ENUM FOR HANDLING SCREEN STATES LIKE LOAIDNG, SUCCESS WITH DATA, EMPTY DATA, ERROR ETC. AND ALSO CREATE A GENERIC SHIMMER WHICH WE CAN USE IN EVERY WHERE.

@MainActor
final class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let networkService: NetworkProtocol
    
    init(networkService: NetworkProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedProducts: [Product] = try await networkService.dataRequest(with: ProductRouter.products(0, 10))
            self.products = fetchedProducts
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

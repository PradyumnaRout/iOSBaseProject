//
//  ProductListViewModel.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation
import Combine

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

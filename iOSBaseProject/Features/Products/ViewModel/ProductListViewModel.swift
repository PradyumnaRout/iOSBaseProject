//
//  ProductListViewModel.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation
import Combine


// MARK: MODIFY THIS TO DEPENDECNY INJECTION PATTERN USING A PRODUCT SERVICE REPOSITOY FOR API CALL INSTEAD OF DIRECLTY USING NETWORKPROTOCOL RIGHT HERE. AND ALSO CREATE SCREEN STATE PUBLIC ENUM FOR HANDLING SCREEN STATES LIKE LOAIDNG, SUCCESS WITH DATA, EMPTY DATA, ERROR ETC. AND ALSO CREATE A GENERIC SHIMMER WHICH WE CAN USE IN EVERY WHERE.

import Foundation
import SwiftUI
import Combine


@MainActor
final class ProductListViewModel: ObservableObject {

    @Published var isLoadingNextPage = false
    @Published var loadingState: ViewStates<[Product]> = .loading

    var service: ProductService

    private let limit = 10
    private var offset = 0
    private let totalCount = 50
    private var isRefreshing = false

    init(service: ProductService) {
        self.service = service
        Task { await loadProducts() }
    }

    // Initial load + pagination
    func loadProducts() async {
        let requestedOffset = offset

        defer { isLoadingNextPage = false }

        do {
            let data: [Product] = try await service.getproducts(
                with: ProductRouter.products(requestedOffset, limit))

            if requestedOffset == 0 {
                loadingState = data.isEmpty ? .empty : .loaded(data)
            } else if !data.isEmpty {
                insertProduct(data)
            }
        } catch {
            if isCancellation(error) { return }
            if requestedOffset == 0 {
                loadingState = .failed("Something Went Wrong!")
            } else {
                offset = max(0, offset - limit) // allow retry
                loadingState = .failed("Soemthing went wrong!")
            }
        }
    }

    // Pull to refresh: never replaces the list with loading/failed
    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let data: [Product] = try await service.getproducts(with: ProductRouter.products(0, limit))
            offset = 0
            loadingState = data.isEmpty ? .empty : .loaded(data)
        } catch {
            // Keep the existing list on failure or cancellation
            print(error.localizedDescription)
        }
    }

    func loadNextPageifNeeded() {
        guard !isRefreshing, !isLoadingNextPage,
              case .loaded(let products) = loadingState,
              products.count < totalCount else { return }

        isLoadingNextPage = true
        offset = products.count
        
        print("Loading next page")

        Task { await loadProducts() }
    }

    private func insertProduct(_ data: [Product]) {
        guard case .loaded(var products) = loadingState else { return }
        let existing = Set(products.map(\.id))
        products.append(contentsOf: data.filter { !existing.contains($0.id) }) // avoid duplicates
        loadingState = .loaded(products)
    }

    private func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
    }
}

//
//  ProductListView.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation
import SwiftUI

struct ProductListView: View {

    @StateObject private var vm =
    ProductListViewModel(service: ProductionProductService(nwService: NetworkService()))
    @State private var path = NavigationPath()
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .navigationTitle("Products")
                .toolbarTitleDisplayMode(.inlineLarge)
                .logScreen("ProductListView")
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search products"
                )
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch vm.loadingState {
        case .loading:
            ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let error):
            Text(error)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            Text("No Data Found")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let data):
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(data, id: \.id) { product in
                        ProductRow(product: product)
                            .contentShape(Rectangle())
                            .onTapGesture { path.append(product) }
                            .onAppear {
                                if product.id == data.last?.id {
                                    vm.loadNextPageifNeeded()
                                }
                            }
                    }

                    if vm.isLoadingNextPage {
                        ProgressView().padding()
                    }
                }
                .padding(.horizontal)
            }
            .refreshable {
                // Unstructured Task so the refresh isn't cancelled by view updates
                await Task { await vm.refresh() }.value
            }
        }
    }
}

struct ProductRow: View {
    var product: Product
    @State private var showFullDescription: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(product.title)
                    .font(.headline)
                Spacer()
                Text("\(product.price)")
                    .font(.headline)
                    .padding(.leading, 25)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(product.slug)
                    .font(.callout)
                Text(product.description)
                    .lineLimit(showFullDescription ? nil : 3)
                    .font(.caption2)
                Text(showFullDescription ? "Show Less" : "Show More")
                    .foregroundStyle(.blue)
                    .font(.caption2)
                    .onTapGesture {
                        showFullDescription.toggle()
                    }
            }
            
            // Images
            HStack {
                ForEach(Array(product.images.enumerated()), id: \.offset) { _, image in
                    AsyncImage(url: URL(string: image)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .failure:
                            Image(systemName: "photo").foregroundStyle(.secondary)
                        default:
                            ProgressView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.gray, lineWidth: 1)
        }
        .clipped()
    }
}



#Preview {
    ProductListView()
}




struct ProductDetailView: View {
    var product: Product
    
    var body: some View {
        VStack {
            Text(product.title)
            
            Text(product.slug)
            
            Text(product.description)
        }
        .navigationTitle("Product Details")
    }
}

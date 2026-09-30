//
//  ProductListView.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Products...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Products")
                            .font(.title2)
                            .bold()
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            Task {
                                await viewModel.fetchProducts()
                            }
                        } label: {
                            Text("Retry")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                    }
                } else if viewModel.products.isEmpty {
                    ContentUnavailableView("No Products Found", systemImage: "bag")
                } else {
                    List(viewModel.products) { product in
                        HStack(spacing: 12) {
                            if let firstImage = product.images.first, let url = URL(string: firstImage) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Products Demo")
            .task {
                await viewModel.fetchProducts()
            }
        }
    }
}

#Preview {
    ProductListView()
}

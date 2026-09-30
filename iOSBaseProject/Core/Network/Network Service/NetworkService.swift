//
//  NetworkService.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

/// Network Protocol
protocol NetworkProtocol {
    func dataRequest<T: Decodable>(with router: RouterProtocol) async throws -> T
}

/// Network Service
class NetworkService: NetworkProtocol {
    func dataRequest<T: Decodable>(
        with router: RouterProtocol
    ) async throws -> T {
        do {
            // 1. Create the URL Request
            let urlRequest = try router.buildUrlRequest()
            NetworkLogger.logRequest(for: router, urlRequest: urlRequest)
            
            // 2. Perform Network Data Task
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let httpResponse = response as? HTTPURLResponse
            
            // 3. Validate HTTP Response & Status Code
            guard let httpResponse = httpResponse else {
                let error = NetworkError.invalidResponse
                NetworkLogger.logResponse(response: nil, data: data, error: error)
                throw error
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = NetworkError.from(statusCode: httpResponse.statusCode)
                NetworkLogger.logResponse(response: httpResponse, data: data, error: error)
                throw error
            }
            
            // 4. Decode JSON Data
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            NetworkLogger.logResponse(response: httpResponse, data: data, decodedObject: decodedData)
            return decodedData
            
        } catch let networkError as NetworkError {
            throw AppError.from(networkError)
        } catch let appError as AppError {
            throw appError
        } catch {
            let mappedNetworkError = NetworkError.mapError(error)
            NetworkLogger.logResponse(response: nil, data: nil, error: mappedNetworkError)
            throw AppError.from(mappedNetworkError)
        }
    }
}

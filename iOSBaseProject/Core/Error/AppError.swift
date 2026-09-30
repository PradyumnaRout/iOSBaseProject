//
//  AppError.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

enum AppError: Error, LocalizedError {
    case network(NetworkError)
    case repository(RepositoryError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.errorDescription
        case .repository(let error):
            return error.errorDescription
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    
    // MARK: - Factory & Mapping Helpers
    
    /// Maps an HTTP status code to an `AppError.network`.
    static func from(statusCode: Int) -> AppError {
        let networkError = NetworkError.from(statusCode: statusCode)
        return .network(networkError)
    }
    
    /// Maps a `NetworkError` to an `AppError.network`.
    static func from(_ networkError: NetworkError) -> AppError {
        return .network(networkError)
    }
    
    /// Maps a `RepositoryError` to an `AppError.repository`.
    static func from(_ repositoryError: RepositoryError) -> AppError {
        return .repository(repositoryError)
    }
    
    /// Maps any `Error` (with an optional status code) to the corresponding `AppError`.
    static func from(_ error: Error, statusCode: Int? = nil) -> AppError {
        if let appError = error as? AppError {
            return appError
        } else if let networkError = error as? NetworkError {
            return .network(networkError)
        } else if let repositoryError = error as? RepositoryError {
            return .repository(repositoryError)
        } else if let statusCode = statusCode {
            return from(statusCode: statusCode)
        } else {
            return .unknown(error)
        }
    }
}

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
    
    // MARK: - Factory Throw Methods
    
    /// Throws a network error wrapped in `AppError.network`.
    static func throwNetworkError(_ error: NetworkError) throws -> Never {
        throw AppError.network(error)
    }
    
    /// Throws a network error constructed from an HTTP status code wrapped in `AppError.network`.
    static func throwNetworkError(statusCode: Int) throws -> Never {
        let networkError = NetworkError.from(statusCode: statusCode)
        throw AppError.network(networkError)
    }
    
    /// Throws a repository error wrapped in `AppError.repository`.
    static func throwRepositoryError(_ error: RepositoryError) throws -> Never {
        throw AppError.repository(error)
    }
    
    /// Converts any `Error` (with an optional status code) and throws the corresponding `AppError`.
    static func throwError(_ error: Error, statusCode: Int? = nil) throws -> Never {
        if let appError = error as? AppError {
            throw appError
        } else if let networkError = error as? NetworkError {
            throw AppError.network(networkError)
        } else if let repositoryError = error as? RepositoryError {
            throw AppError.repository(repositoryError)
        } else if let statusCode = statusCode {
            let networkError = NetworkError.from(statusCode: statusCode)
            throw AppError.network(networkError)
        } else {
            throw AppError.unknown(error)
        }
    }
}

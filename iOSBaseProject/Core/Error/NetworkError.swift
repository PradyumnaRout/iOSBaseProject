//
//  NetworkError.swift
//  iOSBaseProject
//
//  Created by Pradyumna Rout on 30/09/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidUrl
    case noInternet
    case decodingFailed
    case encodingFailed
    case invalidResponse
    case requestTimeout
    
    // Client Errors
    case badRequest(statusCode: Int)
    case invalidAuthentication(statusCode: Int)
    case unAuthorized(statusCode: Int)
    case resourceNotAvailable(statusCode: Int)
    case methodNotAllowed(statusCode: Int)
    case duplicateResourceFound(statusCode: Int)
    case tooManyRequests(statusCode: Int)
    
    // Server Errors
    case internalServerError(statusCode: Int)
    case badGateway(statusCode: Int)
    case serviceUnavailable(statusCode: Int)
    case gatewayTimeout(statusCode: Int)
    case others(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl:
            return "The URL provided was invalid."
        case .noInternet:
            return "No internet connection available. Please check your network connection."
        case .decodingFailed:
            return "Failed to decode the response data from the server."
        case .encodingFailed:
            return "Failed to encode swift models/objects to data."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .requestTimeout:
            return "The network request timed out."
            
        // Client Errors
        case .badRequest(let statusCode):
            return "Bad request. (Status code: \(statusCode))"
        case .invalidAuthentication(let statusCode):
            return "Invalid authentication credentials. (Status code: \(statusCode))"
        case .unAuthorized(let statusCode):
            return "Unauthorized access. (Status code: \(statusCode))"
        case .resourceNotAvailable(let statusCode):
            return "The requested resource was not found. (Status code: \(statusCode))"
        case .methodNotAllowed(let statusCode):
            return "HTTP method not allowed. (Status code: \(statusCode))"
        case .duplicateResourceFound(let statusCode):
            return "Duplicate resource found. (Status code: \(statusCode))"
        case .tooManyRequests(let statusCode):
            return "Too many requests. Please try again later. (Status code: \(statusCode))"
            
        // Server Errors
        case .internalServerError(let statusCode):
            return "Internal server error. (Status code: \(statusCode))"
        case .badGateway(let statusCode):
            return "Bad gateway. (Status code: \(statusCode))"
        case .serviceUnavailable(let statusCode):
            return "Service unavailable. (Status code: \(statusCode))"
        case .gatewayTimeout(let statusCode):
            return "Gateway timeout. (Status code: \(statusCode))"
        case .others(let message):
            return message
        }
    }
    
    /// Maps an HTTP status code to its corresponding `NetworkError` case.
    static func from(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400: return .badRequest(statusCode: statusCode)
        case 401: return .invalidAuthentication(statusCode: statusCode)
        case 403: return .unAuthorized(statusCode: statusCode)
        case 404: return .resourceNotAvailable(statusCode: statusCode)
        case 405: return .methodNotAllowed(statusCode: statusCode)
        case 409: return .duplicateResourceFound(statusCode: statusCode)
        case 429: return .tooManyRequests(statusCode: statusCode)
        case 500: return .internalServerError(statusCode: statusCode)
        case 502: return .badGateway(statusCode: statusCode)
        case 503: return .serviceUnavailable(statusCode: statusCode)
        case 504: return .gatewayTimeout(statusCode: statusCode)
        default: return .invalidResponse
        }
    }
    
    /// Centralized mapping of general Swift errors into `NetworkError` cases.
    static func mapError(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternet
            case .timedOut:
                return .requestTimeout
            default:
                return .others(urlError.localizedDescription)
            }
        } else if error is DecodingError {
            return .decodingFailed
        } else if error is EncodingError {
            return .encodingFailed
        } else {
            return .others(error.localizedDescription)
        }
    }
}

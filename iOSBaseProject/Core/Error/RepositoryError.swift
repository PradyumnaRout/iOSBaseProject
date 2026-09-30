//
//  RepositoryError.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

enum RepositoryError: Error, LocalizedError {
    case dataNotFound
    case mappingFailed
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "The requested data could not be found in the repository."
        case .mappingFailed:
            return "Failed to map the repository data to the model."
        case .saveFailed:
            return "Failed to save data to the repository."
        case .fetchFailed:
            return "Failed to fetch data from the repository."
        }
    }
}

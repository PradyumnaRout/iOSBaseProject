//
//  RouterProtocol.swift
//  iOSBaseProject
//
//  Created by Pradyumna Rout on 30/09/26.
//

import Foundation

protocol RouterProtocol {
    var requestTimeOut: Float? { get }
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var header: [String: String]? { get }
    var deviceInfo: [String: Any]? { get }
    var queryItems: [URLQueryItem]? { get }
    var bodyDataCodable: Data? { get throws }
    var bodyDataSerializable: Data? { get throws }
    var files: [MultiPartData]? { get }
}

extension RouterProtocol {
    var requestTimeOut: Float? {
        return 30
    }
    
    var baseUrl: String {
        // return AppEnvironment.baseURl    // make it environment wise later.
        return "https://api.escuelajs.co/api/v1/"
    }
}

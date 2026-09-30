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
    var headers: [String: String]? { get }
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
    
    fileprivate func extractedFunc(_ url: URL) -> URLRequest {
        // Create UrlComponent.
        var urlComponent = URLComponents(string: url.absoluteString)
        if let queryItems {
            urlComponent?.queryItems = queryItems
        }
        
        print("URl:: \(urlComponent?.url?.absoluteString ?? "")")
        var urlRequest = URLRequest(url: urlComponent?.url ?? url)
        urlRequest.httpMethod = method.rawValue
        
        // ✅ Apply headers
        if let header = headers {
            for (key, value) in header {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        return urlRequest
    }
    
    /// Create Build Request
    func buildUrlRequest() throws -> URLRequest {
        let aParam: [String: Any]? = parameters
        let boundary = Boundary.boundary
        
        // Validate Base Url
        guard let baseURL = URL(string: self.baseUrl) else {
            throw NetworkError.invalidUrl
        }
        
        // Construct Final Url with path
        let url: URL
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            guard let pathURL = URL(string: path) else {
                throw NetworkError.invalidUrl
            }
            
            url = pathURL
        } else {
            url = baseURL.appendingPathComponent(path)
        }
        
        
        // URL Request for get method:
        if method == .get {
            return extractedFunc(url)
        }
        
        
        // Request for others::
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        // Apply Headers
        if let headers {
            for (key, value) in headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        urlRequest.timeoutInterval = 300
        let contentType = urlRequest.value(forHTTPHeaderField: "Content-Type")
        
        if (contentType?.contains("multipart/form-data") == true) {
            // If multipart form data
            let dataBody = createDataBody(withParameters: aParam, media: files, boundary: boundary)
            urlRequest.httpBody = dataBody
        } else {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try self.bodyDataSerializable
            urlRequest.httpBody = jsonData
        }
        return urlRequest
        
    }
    
    // Create Data Body for Multipart form Data
    func createDataBody(withParameters parameters: [String: Any]?, media: [MultiPartData]?, boundary: String) -> Data {
        var body = Data()
        if let parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        if let media = media {
            for file in media {
                body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
                body.append("Content-Disposition: form-data; name=\"\(file.paramKey ?? "")\"; filename=\"\(file.fileName ?? "")\"\r\n".data(using: String.Encoding.utf8) ?? Data())
                body.append("Content-Type: \(file.mimeType)\r\n\r\n".data(using: .utf8) ?? Data())
                body.append(file.data ?? Data())
                body.append("\r\n".data(using: .utf8) ?? Data())
            }
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        return body
    }
}

/// Boundary For Multipart Request.
public struct Boundary {
    static public let boundary = "Boundary-\(UUID().uuidString)"
}

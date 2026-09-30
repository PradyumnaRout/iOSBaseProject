//
//  NetworkLogger.swift
//  iOSBaseProject
//
//  Created by Rahul Kiumar on 30/09/26.
//

import Foundation

struct NetworkLogger {
    
    /// Logs outgoing request details.
    static func logRequest(for router: RouterProtocol, urlRequest: URLRequest? = nil) {
        #if DEBUG
        print("\n================= 🚀 OUTGOING REQUEST =================")
        print("BASE URL:   \(router.baseUrl)")
        print("PATH:       \(router.path)")
        print("FULL URL:   \(urlRequest?.url?.absoluteString ?? (router.baseUrl + router.path))")
        print("HTTP VERB:  \(router.method.rawValue)")
        print("HEADERS:    \(router.headers ?? [:])")
        print("PARAMETERS: \(router.parameters ?? [:])")
        if let bodyData = urlRequest?.httpBody {
            if let prettyBody = prettyPrintedJSON(from: bodyData) {
                print("HTTP BODY (JSON):\n\(prettyBody)")
            } else if let bodyString = String(data: bodyData, encoding: .utf8) {
                print("HTTP BODY:  \(bodyString)")
            }
        }
        print("========================================================\n")
        #endif
    }
    
    /// Logs incoming response details and JSON output.
    static func logResponse(
        response: HTTPURLResponse?,
        data: Data?,
        decodedObject: Any? = nil,
        error: Error? = nil
    ) {
        #if DEBUG
        print("\n================= 📥 INCOMING RESPONSE =================")
        if let statusCode = response?.statusCode {
            print("STATUS CODE: \(statusCode)")
        }
        if let url = response?.url?.absoluteString {
            print("URL:         \(url)")
        }
        
        if let decodedObject = decodedObject {
            print("MODEL TYPE:  \(type(of: decodedObject))")
            // Commented out Swift model format printing:
            // print("DECODED:     \(decodedObject)")
        }
        
        if let data = data, let jsonString = prettyPrintedJSON(from: data) {
            print("RESPONSE JSON:\n\(jsonString)")
        }
        
        if let error = error {
            print("ERROR:       \(error.localizedDescription)")
        }
        print("========================================================\n")
        #endif
    }
    
    /// Formats raw Data into a pretty-printed JSON string.
    private static func prettyPrintedJSON(from data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8)
        }
        return prettyString
    }
}

//
//  Token.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation


enum ExtoleApiError {
    case serverError(error: Error)
    case decodingError
    case noContent
    case genericError
}

enum VerifyTokenError : Error {
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}

public struct ConsumerToken : Codable {
    let access_token: String
    let expires_in: Int
    let scopes: [String]
    let capabilities: [String]
}

extension Program {

    public func getToken() -> APIResponse<ConsumerToken> {
        let url = URL(string: "\(baseUrl)/api/v4/token")!
        return dataTask(url: url, accessToken: nil, postData: nil)
    }
    
    public func verifyToken(token: String, callback : @escaping (_: ConsumerToken?, _: VerifyTokenError?) -> Void) {
        let session = newSession();
        let url = URL(string: "\(baseUrl)/api/v4/token/\(token)")!
        let request = newRequest(url: url)
        
        func mapVerifyError(errorCode: String) -> VerifyTokenError? {
            switch(errorCode) {
                case "invalid_access_token": return .invalidAccessToken
                default: return .invalidProtocol(error: .genericError)
            }
        }
        
        func processResponse(data: Data?, response: URLResponse?, error: Error?) {
            if let serverError = error {
                callback(nil, .invalidProtocol(error: .serverError(error: serverError)))
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let responseData = data {
                        let decodedError: ErrorData? = tryDecode(data: responseData)
                        if let decodedError = decodedError {
                            callback(nil, mapVerifyError(errorCode: decodedError.code))
                        } else {
                            callback(nil, .invalidProtocol(error: .decodingError))
                        }
                    } else {
                        callback(nil, .invalidProtocol(error:.noContent))
                    }
                    return
            }
            if let responseData = data {
                Logger.Debug(message: String(data: responseData, encoding: String.Encoding.utf8)!)
                let decodedData: ConsumerToken? = tryDecode(data: responseData)
                if let decodedData = decodedData {
                    callback(decodedData, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError))
                }
            } else {
                callback(nil, .invalidProtocol(error: .noContent))
            }
        }
       
        let task = session.dataTask(with: request, completionHandler: processResponse)
        task.resume()
    }
}


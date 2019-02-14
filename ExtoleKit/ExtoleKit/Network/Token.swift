//
//  Token.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public enum ExtoleApiError {
    case serverError(error: Error)
    case decodingError(data: Data)
    case noContent
    case genericError(errorData: ErrorData)
}

public enum GetTokenError : Error {
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}

public struct ConsumerToken : Codable {
    init(access_token: String) {
        self.access_token = access_token
    }
    public let access_token: String
    let expires_in: Int? = nil
    let scopes: [String]? = nil
    let capabilities: [String]? = nil
}

func tokenUrl(baseUrl: URL) -> URL {
    return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
}

private func procesTokenRequest(with request: URLRequest, responseHandler: @escaping (_: ConsumerToken?, _: GetTokenError?) ->Void) {
    extoleDebug(format: "request %{public}@ ", arg: request.url?.absoluteString ?? "url is empty")
    processRequest(with: request) { data, error in
        if let apiError = error {
            switch(apiError) {
            case .genericError(let errorData) : do {
                switch(errorData.code) {
                case "invalid_access_token": responseHandler(nil, .invalidAccessToken)
                default:  responseHandler(nil, .invalidProtocol(error: .genericError(errorData: errorData)))
                }
                }
            default : responseHandler(nil, .invalidProtocol(error: apiError))
            }
            return
        }
        if let data = data {
            let decodedToken : ConsumerToken? = tryDecode(data: data)
            if let token = decodedToken {
                responseHandler(token, nil)
            } else {
                responseHandler(nil, .invalidProtocol(error: .decodingError(data: data)))
            }
        }
    }
}

extension Program {

    public func getToken(callback : @escaping (_: ConsumerToken?, _: GetTokenError?) -> Void) {
        let request = getRequest(url: tokenUrl(baseUrl: baseUrl))
        procesTokenRequest(with: request, responseHandler: callback)
    }
}
extension ProgramSession {
    
    public func getToken(callback : @escaping (_: ConsumerToken?, _: GetTokenError?) -> Void) {
        let url = URL.init(string: token.access_token, relativeTo: tokenUrl(baseUrl: baseUrl))!
        let request = getRequest(url: url)
        procesTokenRequest(with: request, responseHandler: callback)
    }
    
    public func deleteToken(callback : @escaping (_: GetTokenError?) -> Void) {
        let url = URL.init(string: token.access_token, relativeTo: tokenUrl(baseUrl: baseUrl))!
        let request = deleteRequest(url: url)
        extoleDebug(format: "deleteToken : %{public}@", arg: url.absoluteString)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    switch(errorData.code) {
                    case "invalid_access_token": callback(.invalidAccessToken)
                    default:  callback(.invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                    }
                default : callback(.invalidProtocol(error: apiError))
                }
                return
            }
            callback(nil)
        }
    }
}


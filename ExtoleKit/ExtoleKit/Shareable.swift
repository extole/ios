//
//  Shareable.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct PollingIdResponse : Codable {
    let polling_id : String
}

public struct ShareablePollingResult : Codable {
    let polling_id : String
    let status : String
    let code : String?
}

public enum UpdateShareableError : Error {
    case invalidProtocol(error: ExtoleApiError)
}

public struct UpdateShareable : Codable {
    public init(data: [String: String]) {
        self.data = data
    }
    public let data: [String: String]?
}

public struct MyShareable : Codable {
    init(label: String, code:String? = nil, key:String? = nil) {
        self.label = label
        self.code = code
        self.key = key
        self.link = nil
        self.data = nil
    }
    public let key: String?
    public let code: String?
    public let label: String?
    public let link: String?
    public let data: [String: String]?
}

extension Program {
    
    public func getShareables(accessToken: ConsumerToken) -> APIResponse<[MyShareable]> {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        return dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
    }
    
    public func updateShareable(accessToken: ConsumerToken, code: String, shareable: UpdateShareable,
                                callback : @escaping (UpdateShareableError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/\(code)")!
        let request = putRequest(accessToken: accessToken,
                                  url: url,
                                  data: shareable)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    callback(.invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                default : callback(.invalidProtocol(error: apiError))
                }
                return
            }
            callback(nil)
        }
        
    }

    public func createShareable(accessToken: ConsumerToken, shareable: MyShareable)
        -> APIResponse<PollingIdResponse> {
            let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
            let shareableData = try? JSONEncoder().encode(shareable)
            return dataTask(url: url, accessToken: accessToken.access_token, postData: shareableData)
    }

    public func pollShareable(accessToken: ConsumerToken, pollingResponse: PollingIdResponse)
        -> APIResponse<ShareablePollingResult> {
            let url = URL(string: "\(baseUrl)/api/v5/me/shareables/status/\(pollingResponse.polling_id)")!
            return dataTask(url: url, accessToken: accessToken.access_token, postData: nil)
    }
}

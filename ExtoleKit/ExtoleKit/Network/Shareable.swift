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
public enum GetShareablesError : Error {
    case invalidProtocol(error: ExtoleApiError)
}
public enum CreateShareableError : Error {
    case invalidProtocol(error: ExtoleApiError)
}
public enum PollShareableError : Error {
    case invalidProtocol(error: ExtoleApiError)
}


extension ProgramSession {
    public func getShareables(callback: @escaping ([MyShareable]?, GetShareablesError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let request = getRequest(accessToken: token,
                                 url: url)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    callback(nil, .invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                default : callback(nil, .invalidProtocol(error: apiError))
                }
                return
            }
            if let data = data {
                let decodedShareables : [MyShareable]? = tryDecode(data: data)
                if let decodedShareables = decodedShareables {
                    callback(decodedShareables, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                }
            }
        }
    }
    
    public func updateShareable(code: String, shareable: UpdateShareable,
                                callback : @escaping (UpdateShareableError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/\(code)")!
        let request = putRequest(accessToken: token,
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

    public func createShareable(shareable: MyShareable, callback: @escaping (PollingIdResponse?, CreateShareableError?) -> Void)  {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let request = postRequest(accessToken: token,
                                 url: url,
                                 data: shareable)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    callback(nil, .invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                default : callback(nil, .invalidProtocol(error: apiError))
                }
                return
            }
            if let data = data {
                let decodedPollingId : PollingIdResponse? = tryDecode(data: data)
                if let decodedPollingId = decodedPollingId {
                    callback(decodedPollingId, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                }
            }
        }
    }

    public func pollShareable(pollingResponse: PollingIdResponse,
                              callback: @escaping (ShareablePollingResult?, PollShareableError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/status/\(pollingResponse.polling_id)")!

        let request = getRequest(accessToken: token,
                                 url: url)
        processRequest(with: request) { data, error in
            if let apiError = error {
                switch(apiError) {
                case .genericError(let errorData) : do {
                    callback(nil, .invalidProtocol(error: .genericError(errorData: errorData)))
                    }
                default : callback(nil, .invalidProtocol(error: apiError))
                }
                return
            }
            if let data = data {
                let decodedPollingId : ShareablePollingResult? = tryDecode(data: data)
                if let decodedPollingId = decodedPollingId {
                    callback(decodedPollingId, nil)
                } else {
                    callback(nil, .invalidProtocol(error: .decodingError(data: data)))
                }
            }
        }
    }
}

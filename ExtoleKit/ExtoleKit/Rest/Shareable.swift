//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct PollingIdResponse : Codable {
    let polling_id : String
}

public struct ShareablePollingResult : Codable {
    public let polling_id : String
    public let status : String
    public let code : String?
}

public enum UpdateShareableError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
        case "invalid_access_token": return UpdateShareableError.invalidAccessToken
        default: return nil
        }
    }

    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return GetProfileError.invalidProtocol(error: error)
    }
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}

public struct UpdateShareable : Codable {
    public init(data: [String: String]) {
        self.data = data
    }
    public let data: [String: String]?
}

@objc public final class MyShareable : NSObject, Codable {
    public init(label: String, code:String? = nil, key:String? = nil) {
        self.label = label
        self.code = code
        self.key = key
        self.link = nil
        self.data = nil
    }
    @objc public let key: String?
    @objc public let code: String?
    @objc public let label: String?
    @objc public let link: String?
    @objc public let data: [String: String]?
}
public enum GetShareablesError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
        case "invalid_access_token": return GetShareablesError.invalidAccessToken
        default: return nil
        }
    }
    
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return GetShareablesError.invalidProtocol(error: error)
    }
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}
public enum CreateShareableError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
        case "invalid_access_token": return GetShareablesError.invalidAccessToken
        default: return nil
        }
    }
    
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return CreateShareableError.invalidProtocol(error: error)
    }
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}
public enum PollShareableError : ExtoleError {
    public static func fromCode(code: String) -> ExtoleError? {
        switch(code) {
        case "invalid_access_token": return PollShareableError.invalidAccessToken
        default: return nil
        }
    }
    
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return PollShareableError.invalidProtocol(error: error)
    }
    case invalidProtocol(error: ExtoleApiError)
    case invalidAccessToken
}


extension ConsumerSession {
    public func getShareables(success: @escaping ([MyShareable]?) -> Void,
                              error: @escaping (GetShareablesError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let request = self.network.getRequest(accessToken: token,
                                 url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
    
    @objc public func getShareable(code: String, success: @escaping (MyShareable?) -> Void,
                              error errorCallback: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/shareables/\(code)")!
        let request = self.network.getRequest(accessToken: token,
                                              url: url)
        self.network.processRequest(with: request, success: success, error: { (error:GetShareablesError) in
            errorCallback(String(describing: error))
        })
    }
    
    public func updateShareable(code: String,
                                shareable: UpdateShareable,
                                success: @escaping () -> Void,
                                error : @escaping (UpdateShareableError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/\(code)")!
        let request = self.network.putRequest(accessToken: token,
                                  url: url,
                                  data: shareable)
        self.network.processNoContentRequest(with: request, success: success, error: error)
    }

    public func createShareable(shareable: MyShareable,
                                success: @escaping (PollingIdResponse?) -> Void,
                                error: @escaping (CreateShareableError?) -> Void)  {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables")!
        let request = self.network.postRequest(accessToken: token,
                                 url: url,
                                 data: shareable)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func pollShareable(pollingResponse: PollingIdResponse,
                              success: @escaping (ShareablePollingResult?) -> Void,
                              error: @escaping (PollShareableError?) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/me/shareables/status/\(pollingResponse.polling_id)")!

        let request = self.network.getRequest(accessToken: token,
                                 url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }
}

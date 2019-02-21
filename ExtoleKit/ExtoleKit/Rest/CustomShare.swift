//Copyright © 2019 Extole. All rights reserved.

import Foundation
public struct CustomShare : Codable {
    public init(advocate_code: String, channel: String, message : String? = nil, recipient_email: String? = nil,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.channel = channel
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }
    let advocate_code: String
    let channel: String
    let message: String?
    let recipient_email: String?
    let data: [String:String]?
}

public enum CustomShareError : ExtoleError {
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return CustomShareError.invalidProtocol(error: error)
    }
    
    public static func fromCode(code: String) -> ExtoleError? {
        return nil
    }
    
    case invalidProtocol(error: ExtoleApiError)
}

public enum PollShareError : ExtoleError {
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return PollShareError.invalidProtocol(error: error)
    }
    
    public static func fromCode(code: String) -> ExtoleError? {
        return nil
    }
    
    case invalidProtocol(error: ExtoleApiError)
    case pollingTimeout
}

public struct CustomSharePollingResult : Codable {
    let polling_id : String
    let status : String
    let share_id : String?
}

extension ConsumerSession {
    
    public func customShare(share: CustomShare,
                            success : @escaping (PollingIdResponse?) -> Void,
                            error: @escaping (CustomShareError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share")!
        let request = network.postRequest(accessToken: token,
                                  url: url,
                                  data: share)
        network.processRequest(with: request, success: success, error: error)
    }
    
    public func getCustomShareStatus(pollingResponse: PollingIdResponse,
                                success : @escaping (CustomSharePollingResult?) -> Void,
                                error: @escaping(PollShareError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share/status/\(pollingResponse.polling_id)")!
        let request = self.network.getRequest(accessToken: token,
                                 url: url)
        
        self.network.processRequest(with: request, success: success, error: error)
    }
    
    public func pollCustomShare(pollingResponse: PollingIdResponse,
                                     success : @escaping (CustomSharePollingResult?) -> Void,
                                     error: @escaping(PollShareError) -> Void) {
        func poll(retries: UInt) {
            getCustomShareStatus(pollingResponse: pollingResponse,
                                 success: { pollingResult in
                                    if let pollingStatus = pollingResult?.status {
                                        if pollingStatus == "SUCCEEDED" {
                                            success(pollingResult)
                                        } else if retries > 0 {
                                            sleep(1)
                                            poll(retries: retries - 1)
                                        } else {
                                            error(.pollingTimeout)
                                        }
                                    }
            }, error: { pollingError in
                error(pollingError)
            })
        }
            
        poll(retries: 10)
    }
    
}

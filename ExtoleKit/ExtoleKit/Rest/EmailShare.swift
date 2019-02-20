//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct EmailShare : Codable {
    public init(advocate_code: String, recipient_email: String? = nil,
         message: String? = nil,
         subject: String? = nil,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.subject = subject
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }
    let advocate_code: String
    let message: String?
    let subject: String?
    let recipient_email: String?
    let data: [String:String]?
}

public enum EmailShareError : ExtoleError {
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return EmailShareError.invalidProtocol(error: error)
    }
    
    public static func fromCode(code: String) -> ExtoleError? {
        return nil
    }
    
    case invalidProtocol(error: ExtoleApiError)
}

public enum PollEmailShareError : ExtoleError {
    public static func toInvalidProtocol(error: ExtoleApiError) -> ExtoleError {
        return PollEmailShareError.invalidProtocol(error: error)
    }
    
    public static func fromCode(code: String) -> ExtoleError? {
        return nil
    }
    
    case invalidProtocol(error: ExtoleApiError)
    case pollingTimeout
}

public struct EmailSharePollingResult : Codable {
    let polling_id : String
    let status : String
    let share_id : String
}

extension ConsumerSession {
    
    public func emailShare(share: EmailShare,
                           success : @escaping (PollingIdResponse?) -> Void,
                           error: @escaping (EmailShareError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/email/share")!
        let request = self.network.postRequest(accessToken: token,
                                  url: url,
                                  data: share)
        network.processRequest(with: request, success: success, error: error)
    }
    
    public func getEmailShareStatus(pollingResponse: PollingIdResponse,
                                    success : @escaping (EmailSharePollingResult?) -> Void,
                                    error: @escaping (PollEmailShareError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/email/share/status/\(pollingResponse.polling_id)")!
        let request = self.network.getRequest(accessToken: token,
                                              url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func pollEmailShare(pollingResponse: PollingIdResponse,
                                success : @escaping (EmailSharePollingResult?) -> Void,
                                error: @escaping (PollEmailShareError) -> Void) {
        func poll(retries: UInt = 10) {
            getEmailShareStatus(pollingResponse: pollingResponse, success: { pollingResult in
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
            }, error : { pollingError in
                error(pollingError)
            })
        }
        poll(retries: 10)
    }
    
}

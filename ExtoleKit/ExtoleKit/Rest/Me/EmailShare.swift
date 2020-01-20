//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class EmailShare : NSObject, Codable {
    public init(advocate_code: String? = nil, recipient_email: String,
         message: String,
         subject: String? = nil,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.subject = subject
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }
    var advocate_code: String?
    var message: String
    var subject: String?
    var recipient_email: String?
    var data: [String:String]?
}

@objc public final class EmailSharePollingResult : NSObject, Codable {
    let polling_id : String
    let status : String
    let share_id : String?
}

extension ExtoleAPI.Session {
    
    public func emailShare(share: EmailShare,
                           success : @escaping (PollingIdResponse?) -> Void,
                           error: @escaping (ExtoleAPI.Error) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/email/share")!
        let request = self.postRequest(url: url, data: share)
        network.processRequest(with: request, success: success, error: error)
    }
    
    public func getEmailShareStatus(pollingResponse: PollingIdResponse,
                                    success : @escaping (EmailSharePollingResult) -> Void,
                                    error: @escaping (ExtoleAPI.Error) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/email/share/status/\(pollingResponse.polling_id)")!
        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func pollEmailShare(pollingResponse: PollingIdResponse,
                                success : @escaping (EmailSharePollingResult) -> Void,
                                error: @escaping (ExtoleAPI.Error) -> Void) {
        func poll(retries: UInt = 10) {
            getEmailShareStatus(pollingResponse: pollingResponse, success: { pollingResult in
                if pollingResult.status == "SUCCEEDED" {
                    success(pollingResult)
                } else if retries > 0 {
                    sleep(1)
                    poll(retries: retries - 1)
                } else {
                    error(ExtoleAPI.Error.init(code: "polling_timout"))
                }
            }, error : { pollingError in
                error(pollingError)
            })
        }
        poll(retries: 10)
    }
    
}

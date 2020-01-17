//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class CustomShare : NSObject, Codable {
    @objc public init(advocate_code: String? = nil, channel: String, message : String? = nil, recipient_email: String? = nil,
         data: [String:String]? = nil) {
        self.advocate_code = advocate_code
        self.channel = channel
        self.message = message
        self.recipient_email = recipient_email
        self.data = data
    }

    @objc public init(channel: String) {
        self.channel = channel
    }

    var advocate_code: String?
    var channel: String
    var message: String? = nil
    var recipient_email: String? = nil
    var data: [String:String]? = nil
}

@objc public final class CustomSharePollingResult : NSObject, Codable {
    let polling_id : String
    let status : String
    let share_id : String?
}

extension ProgramSession {

    public func customShare(share: CustomShare,
                            success : @escaping (PollingIdResponse) -> Void,
                            error: @escaping (ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share")!
        let request = self.postRequest(url: url,
                                  data: share)
        network.processRequest(with: request, success: success, error: error)
    }
    
    public func getCustomShareStatus(pollingResponse: PollingIdResponse,
                                success : @escaping (CustomSharePollingResult) -> Void,
                                error: @escaping(ExtoleError) -> Void) {
        let url = URL(string: "\(baseUrl)/api/v5/custom/share/status/\(pollingResponse.polling_id)")!
        let request = self.getRequest(url: url)
        
        self.network.processRequest(with: request, success: success, error: error)
    }
    
    public func pollCustomShare(pollingResponse: PollingIdResponse,
                                     success : @escaping (CustomSharePollingResult) -> Void,
                                     error: @escaping(ExtoleError) -> Void) {
        func poll(retries: UInt) {
            getCustomShareStatus(pollingResponse: pollingResponse,
                                 success: { pollingResult in
                                    if pollingResult.status == "SUCCEEDED" {
                                        success(pollingResult)
                                    } else if retries > 0 {
                                        sleep(1)
                                        poll(retries: retries - 1)
                                    } else {
                                        error(ExtoleError.init(code: "polling_timeout"))
                                    }
            }, error: { pollingError in
                error(pollingError)
            })
        }
            
        poll(retries: 10)
    }
    
}

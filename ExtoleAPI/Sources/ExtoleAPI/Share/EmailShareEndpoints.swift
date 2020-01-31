//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    enum Share{
    }
}

private func emailShareUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v6/email/share", relativeTo: baseUrl)!
}

private func emailShareStatusUrl(baseUrl: URL, pollingId: String) -> URL {
   let statusBase = URL.init(string: "/api/v6/email/share/status", relativeTo: baseUrl)!
    return URL.init(string: pollingId, relativeTo: statusBase)!
}

extension ExtoleAPI.Session {
    
    func emailShare(recipient: String,
                    message: String,
                    subject: String,
                    data: [String: String],
                    preferred_code_prefixes : [String]? = nil,
                    key: String? = nil,
                    labels: String? = nil,
                    campaign_id: String? = nil,
                    success: @escaping(_: ExtoleAPI.Share.EmailShareResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = emailShareUrl(baseUrl: self.baseUrl)
        let shareRequest = ExtoleAPI.Share.EmailShareRequest(recipient_email: recipient, message: message, subject: subject, data: data,
            preferred_code_prefixes: preferred_code_prefixes,
            key: key, labels: labels, campaign_id: campaign_id)
        let urlRequest = self.postRequest(url: sharesUrl, data: shareRequest)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
    
    public func getEmailShareStatus(pollingId: String,
                                    success : @escaping (EmailSharePollingResult) -> Void,
                                    error: @escaping (ExtoleAPI.Error) -> Void) {
        let url = emailShareStatusUrl(baseUrl: self.baseUrl, pollingId: pollingId)
        let request = self.getRequest(url: url)
        self.network.processRequest(with: request, success: success, error: error)
    }

    public func pollEmailShare(pollingId: String,
                                success : @escaping (EmailSharePollingResult) -> Void,
                                error: @escaping (ExtoleAPI.Error) -> Void) {
        func poll(retries: UInt = 10) {
            getEmailShareStatus(pollingId: pollingId, success: { pollingResult in
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

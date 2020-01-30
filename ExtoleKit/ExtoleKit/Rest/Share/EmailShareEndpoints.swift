//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    enum Share{
    }
}

private func emailShareUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/v6/email/share", relativeTo: baseUrl)!
}

extension ExtoleAPI.Session {
    
    func emailShare(success: @escaping(_: ExtoleAPI.Share.EmailShareResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = emailShareUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: sharesUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }

}

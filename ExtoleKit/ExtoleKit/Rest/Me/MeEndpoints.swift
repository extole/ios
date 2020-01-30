//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Me {
        static func meUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/me/", relativeTo: baseUrl)!
        }
        static func meSharesUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v4/me/shares/", relativeTo: baseUrl)!
        }
    }
}

extension ExtoleAPI.Session {
    func getShares(success: @escaping(_: [ExtoleAPI.Me.ShareResponse]) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let sharesUrl = ExtoleAPI.Me.meSharesUrl(baseUrl: self.baseUrl)
        let urlRequest = self.getRequest(url: sharesUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
}

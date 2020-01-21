//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ExtoleAPI {
    let baseUrl: URL
    let network : Network
    public init(programDomain: String, network: Network = Network.init()) {
        self.baseUrl = URL.init(string: "https://" + programDomain)!
        self.network = network
    }

    public func createSession(accessToken: String? = nil,
                              tokenRequest: Authorization.CreateTokenRequest? = nil,
                              success : @escaping (_: ExtoleAPI.Session) -> Void,
                              error: @escaping (_: ExtoleAPI.Error) -> Void) {
        if let existingAccessToken = accessToken {
            resumeSession(accessToken: existingAccessToken, success: success, error: error)
        } else {
            let request = self.network.newJsonRequest(method: "POST", url: ExtoleAPI.Authorization.v5TokenUrl(baseUrl: baseUrl), headers: [:], data: tokenRequest)

            self.network.processRequest(with: request, success: {token in
                success(ExtoleAPI.Session(program: self, token: token))
            }, error: error)
        }
   }

   func resumeSession(accessToken: String,
                             success : @escaping (_: ExtoleAPI.Session) -> Void,
                             error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let url = ExtoleAPI.Authorization.v5TokenUrl(baseUrl: baseUrl)
        let empty : String? = nil
        let authorizationHeader = [ "Authorization": accessToken]
        let request = self.network.newJsonRequest(method: "GET", url: url, headers: authorizationHeader, data: empty)
        self.network.processRequest(with: request, success: { token in
            success(ExtoleAPI.Session(program: self, token: token))
        }, error: error)
   }
}

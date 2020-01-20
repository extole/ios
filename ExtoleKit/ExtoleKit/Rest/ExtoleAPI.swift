//Copyright © 2019 Extole. All rights reserved.

import Foundation

public final class ExtoleAPI {
    let baseUrl: URL
    let network : Network
    public init(programDomain: String, network: Network = Network.init()) {
        self.baseUrl = URL.init(string: "https://" + programDomain)!
        self.network = network
    }

    public func createSession(tokenRequest: Token.CreateTokenRequest? = nil,
                              success : @escaping (_: ExtoleAPI.Session) -> Void,
                              error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let request = self.network.newJsonRequest(method: "POST", url: ExtoleAPI.Session.v5TokenUrl(baseUrl: baseUrl), headers: [:], data: tokenRequest)

        self.network.processRequest(with: request, success: {token in
            success(ExtoleAPI.Session(program: self, token: token))
        }, error: error)
   }

   public func resumeSession(accessToken: String,
                             success : @escaping (_: ExtoleAPI.Session) -> Void,
                             error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let url = URL.init(string: accessToken, relativeTo: ExtoleAPI.Session.v4TokenUrl(baseUrl: baseUrl))!
        let empty : String? = nil
        let request = self.network.newJsonRequest(method: "GET", url: url, headers: [:], data: empty)
        self.network.processRequest(with: request, success: { token in
            success(ExtoleAPI.Session(program: self, token: token))
        }, error: error)
   }
}

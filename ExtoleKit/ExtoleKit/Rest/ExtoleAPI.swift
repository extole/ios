//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public final class ExtoleAPI : NSObject {
    let baseUrl: URL
    let network : Network
    @objc public init(programDomain: String, network: Network = Network.init()) {
        self.baseUrl = URL.init(string: "https://" + programDomain)!
        self.network = network
    }

    public func createSession(tokenRequest: Authorization.CreateTokenRequest? = nil,
                              success : @escaping (_: ExtoleSession) -> Void,
                              error: @escaping (_: ExtoleError) -> Void) {
       let request = self.network.newJsonRequest(method: "POST", url: ExtoleSession.v5TokenUrl(baseUrl: baseUrl), headers: [:], data: tokenRequest)

       self.network.processRequest(with: request, success: {token in
           success(ExtoleSession(program: self, token: token))
       }, error: error)
   }

   public func resumeSession(accessToken: String,
                             success : @escaping (_: ExtoleSession) -> Void,
                             error: @escaping (_: ExtoleError) -> Void) {
       let url = URL.init(string: accessToken, relativeTo: ExtoleSession.v4TokenUrl(baseUrl: baseUrl))!
       let empty : String? = nil
       let request = self.network.newJsonRequest(method: "GET", url: url, headers: [:], data: empty)
       self.network.processRequest(with: request, success: { token in
           success(ExtoleSession(program: self, token: token))
       }, error: error)
   }
}

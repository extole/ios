//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

public final class Extole {
    let extoleAPI: ExtoleAPI
    public init(programDomain: String,
         appName: String? = nil,
         appVersion: String? = nil,
         network : Network = Network.init()) {
        self.extoleAPI = ExtoleAPI(programDomain: programDomain,
               appName: appName,
               appVersion: appVersion,
               network: network)
    }
    
    public func session(
        accessToken: String? = nil,
        email: String? = nil,
        jwt: String? = nil,
        delegate: SessionManagerDelegate? = nil) -> ExtoleApp.SessionManager {
        
        return ExtoleApp.SessionManager(accessToken: accessToken,
                                        email: email,
                                        jwt: jwt,
                                        extoleApi: extoleAPI,
                                        delegate: delegate)
    }
}

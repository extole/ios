//Copyright © 2019 Extole. All rights reserved.

import Foundation

import ExtoleAPI

extension ExtoleApp {
    public struct SessionBuilder {
        let extoleAPI: ExtoleAPI
        let errorHandler : (ExtoleAPI.Authorization.CreateSessionError) -> Void
        
        func build(accessToken: String? = nil,
                   email: String? = nil,
                   jwt: String? = nil,
                   success : @escaping (_: ExtoleAPI.Session) -> Void) {
            if let existingToken = accessToken {
                extoleAPI.resumeSession(accessToken: existingToken, success: success, error: { e in
                    self.build(email: email, jwt: jwt, success: success)
                })
            } else {
                extoleAPI.createSession(email: email, success: success, error: errorHandler)
            }
        }
    }
}

extension ExtoleAPI {
    func sessionBuilder(errorHandler : @escaping (ExtoleAPI.Authorization.CreateSessionError) -> Void) -> ExtoleApp.SessionBuilder {
        return ExtoleApp.SessionBuilder(extoleAPI: self, errorHandler: errorHandler)
    }
}

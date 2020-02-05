//Copyright © 2019 Extole. All rights reserved.

import Foundation

import ExtoleAPI

extension ExtoleApp {
    public struct SessionBuilder {
        let extoleAPI: ExtoleAPI
        let errorHandler : (ExtoleAPI.Authorization.CreateSessionError) -> Void
        
        let accessToken: String?
        let email: String?
        let jwt: String?
        
        func resume(accessToken: String) -> SessionBuilder {
            return SessionBuilder(extoleAPI: extoleAPI,
                                  errorHandler: errorHandler,
                                  accessToken: accessToken,
                                  email: email,
                                  jwt: jwt
            )
        }
        
        func identify(email: String? = nil, jwt: String? = nil) -> SessionBuilder {
            return SessionBuilder(extoleAPI: extoleAPI,
                                  errorHandler: errorHandler,
                                  accessToken: accessToken,
                                  email: email,
                                  jwt: jwt
            )
        }
        
        func build(success : @escaping (_: ExtoleAPI.Session) -> Void) {
            if let existingToken = accessToken {
                extoleAPI.resumeSession(accessToken: existingToken, success: success, error: { e in
                    SessionBuilder(extoleAPI: self.extoleAPI,
                                   errorHandler: self.errorHandler,
                                   accessToken: nil,
                                   email: self.email,
                                   jwt: self.jwt
                    )
                        .build(success: success)
                })
            } else {
                extoleAPI.createSession(email: email, success: success, error: errorHandler)
            }
        }
    }
}

extension ExtoleAPI {
    func sessionBuilder(errorHandler : @escaping (ExtoleAPI.Authorization.CreateSessionError) -> Void) -> ExtoleApp.SessionBuilder {
        return ExtoleApp.SessionBuilder(extoleAPI: self, errorHandler: errorHandler, accessToken: nil, email: nil, jwt: nil)
    }
}

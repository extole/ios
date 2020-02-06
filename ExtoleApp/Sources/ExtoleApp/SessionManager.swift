//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Handles consumer session events
public protocol SessionManagerDelegate : class {
    func onSessionInvalid()
    func onSessionDeleted()
    func onNewSession(session: ExtoleAPI.Session)
    func onSessionServerError(error: ExtoleAPI.Error)
}

extension ExtoleAPI {
    public func sessionManager(
        accessToken: String? = nil,
        email: String? = nil,
        jwt: String? = nil,
        delegate: SessionManagerDelegate? = nil) -> ExtoleApp.SessionManager {
        return ExtoleApp.SessionManager(accessToken: accessToken,
                                        email: email,
                                        jwt: jwt,
                                        extoleApi: self,
                                        delegate: delegate)
    }
}
/// Manages Extole consumer session
extension ExtoleApp {
public final class SessionManager {
    public typealias Delegate = SessionManagerDelegate
    private let extoleApi: ExtoleAPI
    weak var delegate: SessionManagerDelegate?
    private var session: ExtoleAPI.Session? = nil
    private var activiating: Bool = false
    
    private let serialQueue = DispatchQueue(label: "ExtoleAPI.SessionManager")

    private var accessToken: String? = nil
    let email: String?
    let jwt: String?

    public init(accessToken: String?,
                email: String?,
                jwt: String?,
                extoleApi: ExtoleAPI,
                delegate: SessionManagerDelegate?) {
        self.extoleApi = extoleApi
        self.delegate = delegate
        self.accessToken = accessToken
        self.email = email
        self.jwt = jwt
    }

    public func resume() {
        self.serialQueue.sync {
            self.session = nil
            self.activate()
        }
    }

    public func logout() {
        self.serialQueue.sync {
            if let existingSession = session {
                existingSession.invalidate(success: {
                    self.delegate?.onSessionDeleted()
                }) { e in
                    self.delegate?.onSessionServerError(error: e);
                }
            }
            self.session = nil
            self.activate()
        }
    }

/// Async support
    private var asyncCommands : [(ExtoleAPI.Session) -> Void] = []

    public func async(command: @escaping (ExtoleAPI.Session) -> Void ) {
        self.serialQueue.sync {
            if let existingSession = self.session {
                command(existingSession)
                return
            } else {
                asyncCommands.append(command)
                self.activate()
            }
        }
    }
    
    private func activate() {
        if (activiating) {
            return
        }
        activiating = true
        ExtoleApp.SessionBuilder.init(extoleAPI: extoleApi, errorHandler: { e in
            self.delegate?.onSessionServerError(error: e.error);
            }).build(accessToken: accessToken,
                     email: email,
                     jwt: jwt,
                     success: { session in
            self.accessToken = session.accessToken
            self.session = session
            self.activiating = false
            self.delegate?.onNewSession(session: session)
            self.runCommands(session: session)
        })
    }
    
    private func runCommands(session: ExtoleAPI.Session) {
        self.serialQueue.async {
            let commands = self.asyncCommands
            self.asyncCommands = []
            commands.forEach { command in
                command(session)
            }
        }
    }
}
}

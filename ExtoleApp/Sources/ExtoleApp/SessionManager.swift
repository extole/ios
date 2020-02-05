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
    public func sessionManager(delegate: SessionManagerDelegate? = nil) -> ExtoleApp.SessionManager {
        return ExtoleApp.SessionManager(extoleApi: self, delegate: delegate)
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
    private let accessToken: String? = nil
    private let serialQueue = DispatchQueue(label: "ExtoleAPI.SessionManager")

    private var email: String? = nil
    private var jwt: String? = nil

    public init(extoleApi: ExtoleAPI, delegate: SessionManagerDelegate?) {
        self.extoleApi = extoleApi
        self.delegate = delegate
    }

    public func resume(accessToken: String) {
        extoleApi.resumeSession(accessToken: accessToken, success: { session in
            self.session = session
            self.delegate?.onNewSession(session: session)
        }, error: { e in
            if e.code != nil {
                self.delegate?.onSessionInvalid()
            } else {
                self.delegate?.onSessionServerError(error: e.error)
            }
        })
    }

    public func identify(email: String? = nil, jwt: String? = nil) -> SessionManager {
        self.serialQueue.sync {
            self.session = nil
            self.email = email
            self.jwt = jwt
            self.activate()
        }
        return self
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
            self.email = nil
            self.jwt = nil
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
            }
            self.activate()
        }
    }
    
    private func activate() {
        if (activiating) {
            return
        }
        activiating = true
        self.extoleApi.createSession(email: self.email,
                                     jwt: self.jwt,
                                     success: { session in
            self.session = session
            self.activiating = false
            self.delegate?.onNewSession(session: session)
            self.runCommands(session: session)
        }, error: { e in
            self.delegate?.onSessionServerError(error: e.error);
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

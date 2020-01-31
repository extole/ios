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
    public func sessionManager(delegate: SessionManagerDelegate? = nil) -> SessionManager {
        return SessionManager(extoleApi: self, delegate: delegate)
    }
}
/// Manages Extole consumer session
public final class SessionManager {
    public typealias Delegate = SessionManagerDelegate
    private let extoleApi: ExtoleAPI
    weak var delegate: SessionManagerDelegate?
    private var session: ExtoleAPI.Session? = nil
    private var activiating: Bool = false
    private let accessToken: String? = nil
    private let serialQueue = DispatchQueue(label: "ExtoleAPI.SessionManager")

    public init(extoleApi: ExtoleAPI, delegate: SessionManagerDelegate?) {
        self.extoleApi = extoleApi
        self.delegate = delegate
    }
    
    public func reload() {
        self.session!.verify(success: { verifiedToken in
            self.onSessionResume(session: self.session!)
        }, error: { verifyTokenError in
            if (verifyTokenError.isInvalidAccessToken() ||
                verifyTokenError.isExpiredAccessToken() ||
                verifyTokenError.isInvalidProgramDomain()) {
                self.delegate?.onSessionInvalid()
            } else {
                self.delegate?.onSessionServerError(error: verifyTokenError)
            }
        })
    }

    public func resumeSession(existingToken: String) {
        extoleApi.createSession(accessToken: existingToken, success: { session in
            self.onSessionResume(session: session)
        }, error: { verifyTokenError in
            if (verifyTokenError.isInvalidAccessToken() ||
                verifyTokenError.isExpiredAccessToken() ||
                verifyTokenError.isInvalidProgramDomain()) {
                self.delegate?.onSessionInvalid()
            } else {
                self.delegate?.onSessionServerError(error: verifyTokenError)
            }
        })
    }
    
    public func newSession() {
        self.session = nil
        self.extoleApi.createSession(success: { session in
            self.onSessionResume(session: session)
        }, error: { error in
            self.delegate?.onSessionServerError(error: error);
        })
    }
    
    public func logout() {
        if let session = session {
            session.invalidate(success: {
                self.delegate?.onSessionDeleted()
            }, error: { error in
                self.delegate?.onSessionServerError(error: error);
            })
        }
        
    }
    
    private func onSessionResume(session: ExtoleAPI.Session) {
        self.session = session
        self.delegate?.onNewSession(session: self.session!)
    }

/// Async support
    private var asyncCommands : [(ExtoleAPI.Session) -> Void] = []

    public func async(command: @escaping (ExtoleAPI.Session) -> Void ) {
       if let existingSession = self.session {
           command(existingSession)
       } else {
           asyncCommands.append(command)
            self.serialQueue.async {
                self.activate()
            }
       }
    }
    
    private func activate() {
        if (activiating) {
            return
        }
        activiating = true
        self.extoleApi.createSession(success: { session in
            self.session = session
            self.activiating = false
            self.delegate?.onNewSession(session: session)
            self.runCommands(session: session)
        }, error: { error in
            self.delegate?.onSessionServerError(error: error);
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

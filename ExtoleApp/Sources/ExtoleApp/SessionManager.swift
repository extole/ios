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

/// Manages Extole consumer session
public final class SessionManager {
    let program: ExtoleAPI
    weak var delegate: SessionManagerDelegate?
    private var session: ExtoleAPI.Session? = nil

    public init(program: ExtoleAPI, delegate: SessionManagerDelegate) {
        self.program = program
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
        program.createSession(accessToken: existingToken, success: { session in
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
        self.program.createSession(success: { session in
            self.session = session
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
}

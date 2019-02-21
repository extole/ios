//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles consumer session events
public protocol SessionManagerDelegate : class {
    func onSessionInvalid()
    func onSessionDeleted()
    func onNewSession(session: ConsumerSession)
    func onSessionServerError(error: ExtoleError)
}

/// Manages Extole consumer session
public final class SessionManager {
    let program: ProgramURL
    weak var delegate: SessionManagerDelegate?
    private var session: ConsumerSession? = nil

    public init(program: ProgramURL, delegate: SessionManagerDelegate) {
        self.program = program
        self.delegate = delegate
    }
    
    public func reload() {
        self.session!.getToken(success: { verifiedToken in
            self.onVerifiedToken(verifiedToken: verifiedToken!)
        }, error: { verifyTokenError in
            switch(verifyTokenError) {
            case .invalidAccessToken: self.delegate?.onSessionInvalid()
            case .expiredAccessToken: self.delegate?.onSessionInvalid()
            case .invalidProgramDomain: self.delegate?.onSessionInvalid()
            default: self.delegate?.onSessionServerError(error: verifyTokenError)
            }
        })
    }

    public func resumeSession(existingToken: String) {
        let consumerToken = ConsumerToken.init(access_token: existingToken)
        self.session = ConsumerSession.init(program: self.program, token: consumerToken)
        self.session!.getToken(success: { verifiedToken in
            self.onVerifiedToken(verifiedToken: verifiedToken!)
        }, error: { verifyTokenError in
            switch(verifyTokenError) {
            case .invalidAccessToken :self.delegate?.onSessionInvalid()
            case .expiredAccessToken: self.delegate?.onSessionInvalid()
            case .invalidProgramDomain: self.delegate?.onSessionInvalid()
            default: self.delegate?.onSessionServerError(error: verifyTokenError)
            }
        })
    }
    
    public func newSession() {
        self.session = nil
        self.program.getToken(success: { token in
            self.onVerifiedToken(verifiedToken: token!)
        }, error: { error in
            self.delegate?.onSessionServerError(error: error);
        })
    }
    
    public func logout() {
        session!.deleteToken(success: {
            self.delegate?.onSessionDeleted()
        }, error: { error in
            self.delegate?.onSessionServerError(error: error);
        })
    }
    
    private func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.session = ConsumerSession.init(program: program, token: verifiedToken)
        self.delegate?.onNewSession(session: self.session!)
    }
}

//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles consumer session events
public protocol SessionManagerDelegate : class {
    func onSessionInvalid()
    func onSessionDeleted()
    func onNewSession(session: ProgramSession)
    func onSessionServerError(error: ExtoleError)
}

/// Manages Extole consumer session
public final class SessionManager {
    let program: ExtoleAPI
    weak var delegate: SessionManagerDelegate?
    private var session: ProgramSession? = nil

    public init(program: ExtoleAPI, delegate: SessionManagerDelegate) {
        self.program = program
        self.delegate = delegate
    }
    
    public func reload() {
        self.session!.verify(success: { verifiedToken in
            self.onVerifiedToken(verifiedToken: verifiedToken)
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
        let consumerToken = ConsumerToken.init(access_token: existingToken)
        self.session = ProgramSession.init(program: self.program,
                                            token: consumerToken)
        self.session!.verify(success: { verifiedToken in
            self.onVerifiedToken(verifiedToken: verifiedToken)
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
        self.program.createToken(success: { token in
            self.onVerifiedToken(verifiedToken: token)
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
    
    private func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.session = ProgramSession.init(program: program, token: verifiedToken)
        self.delegate?.onNewSession(session: self.session!)
    }
}

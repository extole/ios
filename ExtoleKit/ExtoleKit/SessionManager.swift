//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol SessionManagerDelegate : class {
    func tokenInvalid()
    func tokenDeleted()
    func tokenVerified(token: ConsumerToken)
    func serverError(error: GetTokenError)
}

public final class SessionManager {
    let program: Program
    weak var delegate: SessionManagerDelegate?
    public var session: ProgramSession? = nil

    public init(program: Program, delegate: SessionManagerDelegate) {
        self.program = program
        self.delegate = delegate
    }
    
    public func resumeSession(existingToken: String) {
        let consumerToken = ConsumerToken.init(access_token: existingToken)
        self.session = ProgramSession.init(program: self.program, token: consumerToken)
        self.session!.getToken(success: { verifiedToken in
            self.onVerifiedToken(verifiedToken: verifiedToken!)
        }, error: { verifyTokenError in
            switch(verifyTokenError) {
            case .invalidAccessToken :self.delegate?.tokenInvalid()
            default: self.delegate?.serverError(error: verifyTokenError)
            }
        })
    }
    
    public func newSession() {
        self.session = nil
        self.program.getToken(success: { token in
            self.onVerifiedToken(verifiedToken: token!)
        }, error: { error in
            self.delegate?.serverError(error: error);
        })
    }
    
    public func logout() {
        session!.deleteToken(success: {
            self.delegate?.tokenDeleted();
        }, error: { error in
            self.delegate?.serverError(error: error);
        })
    }
    
    private func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.session = ProgramSession.init(program: program, token: verifiedToken)
        self.delegate?.tokenVerified(token: verifiedToken)
    }
}

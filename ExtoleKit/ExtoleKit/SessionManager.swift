//Copyright © 2019 Extole. All rights reserved.

import Foundation

public enum SessionState {
    case Init
    case LoggedOut
    case Inactive
    case InvalidToken
    case ServerError
    case Verified(token: ConsumerToken)
}

public protocol SessionStateListener : AnyObject {
    func onStateChanged(state: SessionState)
}

public final class SessionManager {
    let program: Program
    weak var listener: SessionStateListener?
    public var session: ProgramSession? = nil
    var state = SessionState.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: "\(state)")
            listener?.onStateChanged(state: state)
        }
    }

    public init(program: Program, listener: SessionStateListener?) {
        self.program = program
        self.listener = listener
    }
    
    public func activate(existingToken: String) {
        let consumerToken = ConsumerToken.init(access_token: existingToken)
        self.session = ProgramSession.init(program: self.program, token: consumerToken)
        self.session!.getToken(success: { verifiedToken in
            self.onVerifiedToken(verifiedToken: verifiedToken!)
        }, error: { verifyTokenError in
            switch(verifyTokenError) {
            case .invalidAccessToken : self.onTokenInvalid()
            default: self.onServerError()
            }
        })
    }
    
    private func onTokenInvalid() {
        self.state = .InvalidToken
        self.session = nil
        self.program.getToken(success: { token in
            self.onVerifiedToken(verifiedToken: token!)
        }, error: { error in
            self.state = .ServerError
        })
    }

    public func newSession() {
        self.state = .Init
        self.session = nil
        self.program.getToken(success: { token in
            self.onVerifiedToken(verifiedToken: token!)
        }, error: { error in
            self.state = .ServerError
        })
    }
    
    public func logout() {
        session!.deleteToken(success: {
            self.state = .LoggedOut
        }, error: { _ in
            self.state = .ServerError
        })
    }

    private func onServerError() {
        self.state = .ServerError
    }
    
    private func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.session = ProgramSession.init(program: program, token: verifiedToken)
        self.state = .Verified(token: verifiedToken)
    }
}

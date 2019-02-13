//
//  SessionManager.swift
//  ExtoleKit
//
//  Created by rtibin on 2/13/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public enum SessionState : String {
    case Init = "Init"
    case LoggedOut = "LoggedOut"
    case Inactive = "Inactive"
    case InvalidToken = "InvalidToken"
    case ServerError = "ServerError"
    case Verified = "Verified"
}

public protocol SessionStateListener : AnyObject {
    func onStateChanged(state: SessionState)
}

public final class SessionManager {
    let program: Program
    weak var listener: SessionStateListener?
    var session: ProgramSession? = nil
    var state = SessionState.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: state.rawValue)
            listener?.onStateChanged(state: state)
        }
    }

    init(program: Program, listener: SessionStateListener?) {
        self.program = program
        self.listener = listener
    }
    
    public func activate(existingToken: String) {
        let consumerToken = ConsumerToken.init(access_token: existingToken)
        self.session = ProgramSession.init(program: self.program, token: consumerToken)
        self.session!.getToken() { token, error in
            if let verifiedToken = token {
                self.onVerifiedToken(verifiedToken: verifiedToken)
            }
            if let verifyTokenError = error {
                switch(verifyTokenError) {
                case .invalidAccessToken : self.onTokenInvalid()
                default: self.onServerError()
                }
            }
        }
    }
    
    private func onTokenInvalid() {
        self.state = .InvalidToken
        self.session = nil
        self.program.getToken(){ token, error in
            if let newToken = token {
                self.onVerifiedToken(verifiedToken: newToken)
            }
        }
    }

    public func newSession() {
        self.state = .Init
        self.session = nil
        self.program.getToken() { (token, error) in
            if let newToken = token {
                self.onVerifiedToken(verifiedToken: newToken)
            }
        }
    }
    
    public func logout() {
        session!.deleteToken() { error in
            if let _ = error {
                self.state = .ServerError
            } else {
                self.state = .LoggedOut
            }
        }
    }

    private func onServerError() {
        self.state = .ServerError
    }
    
    private func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.session = ProgramSession.init(program: program, token: verifiedToken)
        self.state = .Verified
    }
}

//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ExtoleAppDelegate : class {
    func invalidate()
    func load(session: ProgramSession)
}

public final class ExtoleApp: SessionManagerDelegate {
    private let program: Program
    public let settings = UserDefaults.init()

    lazy private var sessionManager = SessionManager.init(program: program, delegate: self)

    private weak var delegate: ExtoleAppDelegate?
    
    public init(program: Program, delegate: ExtoleAppDelegate?) {
        self.program = program
        self.delegate = delegate
    }
    
    private var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
   
    public func reset() {
        self.savedToken = nil
    }

    public func activate() {
        if let existingToken = self.savedToken {
            self.sessionManager.resumeSession(existingToken: existingToken)
        } else {
            self.sessionManager.newSession()
        }
    }

    public func serverError(error: ExtoleError) {
        
    }
    
    public func onSessionInvalid() {
        delegate?.invalidate()
        self.sessionManager.newSession()
    }
    
    public func onSessionDeleted() {
        delegate?.invalidate()
        self.sessionManager.newSession()
    }
    
    public func onNewSession(session: ProgramSession) {
        self.savedToken = session.accessToken
        delegate?.load(session: session)
    }
}

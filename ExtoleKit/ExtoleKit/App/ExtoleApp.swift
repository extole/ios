//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ExtoleAppDelegate : class {
    func invalidate()
    func load(session: ProgramSession)
}

/// High level API for Extole
public final class ExtoleApp {
    /// stores key-value pairs for Extole
    public let settings = UserDefaults(suiteName: "extoleKit")!
    
    private let program: ProgramURL

    lazy private var sessionManager = SessionManager.init(program: program, delegate: self)

    private weak var delegate: ExtoleAppDelegate?
    
    public init(program: ProgramURL, delegate: ExtoleAppDelegate?) {
        self.program = program
        self.delegate = delegate
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
    
    private var savedToken : String? {
        get {
            return settings.string(forKey: "access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "access_token")
        }
    }
   

}

extension ExtoleApp : SessionManagerDelegate{
    
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

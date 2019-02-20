//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ExtoleAppDelegate : class {
    func initialize()
    func load()
    func ready()
}

open class ExtoleApp {
    private let program: Program

    lazy public private(set) var sessionManager = SessionManager.init(program: program, delegate: self)
    var preloader: Loader?
    
    public weak var delegate: ExtoleAppDelegate?
    
    public init(program: Program) {
        self.program = program
    }
    
    public let settings = UserDefaults.init()
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
    
    public var selectedShareableCode : String? {
        get {
            return settings.string(forKey: "extole.shareable_code")
        }
        set(newShareableKey) {
            settings.set(newShareableKey, forKey: "extole.shareable_code")
        }
    }
    
    public func activate() {
        if let existingToken = self.savedToken {
            self.sessionManager.resumeSession(existingToken: existingToken)
        } else {
            self.sessionManager.newSession()
        }
    }
    
    
}

extension ExtoleApp: SessionManagerDelegate {
    
    public func reload(complete: @escaping () -> Void) {
        if let session = self.sessionManager.session {
            
            session.getToken(success: { token in
                self.delegate?.load()
                self.preloader?.load(session: session, complete: {
                    self.delegate?.ready()
                })
            }) { error in
                complete()
            }
        }
    }
    
    public func serverError(error: ExtoleError) {
        
    }
    
    public func onSessionInvalid() {
        delegate?.initialize()
        self.sessionManager.newSession()
    }
    
    public func onSessionDeleted() {
        delegate?.initialize()
        self.sessionManager.newSession()
    }
    
    public func onNewSession(session: ProgramSession) {
        self.savedToken = session.accessToken
        delegate?.load()
        preloader?.load(session: session, complete: {
            self.delegate?.ready()
        })
    }
}

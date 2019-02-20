//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles events from ExtoleApp
public protocol ExtoleAppDelegate : class {
    /// ExtoleApp is in invalid state
    func extoleAppInvalid()
    /// ExtoleApp is ready
    func extoleAppReady(session: ConsumerSession)
    /// ExtoleApp is ready
    func extoleAppError(error: ExtoleError)
}

/// High level API for Extole
public final class ExtoleApp {
    /// stores key-value pairs for Extole
    public let settings = UserDefaults(suiteName: "extoleKit")!
    /// program url
    private let programUrl: ProgramURL
    /// manages active Extole session
    lazy private var sessionManager = SessionManager.init(program: programUrl, delegate: self)
    /// handles events for ExtoleApp
    private weak var delegate: ExtoleAppDelegate?
    
    /// Initializes ExtoleApp
    public init(with programUrl: ProgramURL, delegate: ExtoleAppDelegate?) {
        self.programUrl = programUrl
        self.delegate = delegate
    }
    
    /// cleans saved data, invalidates delegate
    public func reset() {
        self.savedToken = nil
        self.sessionManager.logout()
    }

    /// Resumes saved session, or creates new one
    public func activate() {
        if let existingToken = self.savedToken {
            self.sessionManager.resumeSession(existingToken: existingToken)
        } else {
            self.sessionManager.newSession()
        }
    }
    
    /// keeps Extole access_token for future runs
    private var savedToken : String? {
        get {
            return settings.string(forKey: "access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "access_token")
        }
    }
}

/// Handlers events from sessionManager
extension ExtoleApp : SessionManagerDelegate{
    
    public func serverError(error: ExtoleError) {
        delegate?.extoleAppError(error: error)
    }
    
    public func onSessionInvalid() {
        delegate?.extoleAppInvalid()
        self.sessionManager.newSession()
    }
    
    public func onSessionDeleted() {
        delegate?.extoleAppInvalid()
    }
    
    public func onNewSession(session: ConsumerSession) {
        self.savedToken = session.accessToken
        delegate?.extoleAppReady(session: session)
    }
}

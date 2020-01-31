//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Handles events from ExtoleApp
public protocol ExtoleAppDelegate : class {
    /// ExtoleApp is in invalid state
    func extoleAppInvalid()
    /// ExtoleApp is ready
    func extoleAppReady(session: ExtoleAPI.Session)
}

/// High level API for Extole
public final class ExtoleApp {
    let errorRecoveryQueue = DispatchQueue(label: "ExtoleApp.errorRecovery")
    var errorCount = 0
    /// stores key-value pairs for Extole
    public let settings = UserDefaults(suiteName: "extoleKit")!
    /// program url
    private let extoleApi: ExtoleAPI
    
    /// manages active Extole session
    lazy private var sessionManager = SessionManager.init(extoleApi: extoleApi, delegate: self)
    /// handles events for ExtoleApp
    private weak var delegate: ExtoleAppDelegate?
    private var session: ExtoleAPI.Session?

    /// Initializes ExtoleApp
    public init(with extoleApi: ExtoleAPI, delegate: ExtoleAppDelegate?) {
        self.extoleApi = extoleApi
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
    
    public func onSessionServerError(error: ExtoleAPI.Error) {
        self.session = nil
        errorCount += 1
        extoleInfo(format: "Session error %{public}@", arg: String(errorCount))
        delegate?.extoleAppInvalid()
        if errorCount > 20 {
            extoleInfo(format: "Max error count reached, giving up")
            return
        }
        let retryAfter = 5.0 * Double(errorCount * errorCount)
        extoleInfo(format: "Schedule error recovery in %{public}@ seconds", arg: String(retryAfter))
        errorRecoveryQueue.asyncAfter(deadline: .now() + retryAfter) {
            if let existingToken = self.savedToken {
                extoleInfo(format: "resuming session after error")
                self.sessionManager.resumeSession(existingToken: existingToken)
            } else {
                extoleInfo(format: "new session after error")
                self.sessionManager.newSession()
            }
        }
    }
    
    public func onSessionInvalid() {
        self.session = nil
        delegate?.extoleAppInvalid()
        savedToken = nil
        self.sessionManager.newSession()
    }
    
    public func onSessionDeleted() {
        self.session = nil
        delegate?.extoleAppInvalid()
        savedToken = nil
        self.sessionManager.newSession()
    }
    
    public func onNewSession(session: ExtoleAPI.Session) {
        self.session = session
        errorCount = 0
        self.savedToken = session.accessToken
        delegate?.extoleAppReady(session: session)
    }
}

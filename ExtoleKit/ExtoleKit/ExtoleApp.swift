//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ExtoleAppStateListener : class {
    func onStateChanged(state: ExtoleApp.State)
}

public final class ExtoleApp {
    
    public enum State : String {
        case Init = "Init"
        case LoggedOut = "LoggedOut"
        case Inactive = "Inactive"
        case InvalidToken = "InvalidToken"
        case ServerError = "ServerError"
        
        case Loading = "Loading"
        
        case Identify = "Identify"
        case Identified = "Identified"
        
        case ReadyToShare = "ReadyToShare"
    }
    
    private let program: Program

    
    public private(set) var sessionManager: SessionManager!
    private var preloader: Loader!
    
    public weak var stateListener: ExtoleAppStateListener?
    
    private init(with program: Program) {
        self.program = program
    }
    
    public convenience init(program: Program, preloader: Loader) {
        self.init(with: program)
        self.sessionManager = SessionManager.init(program: self.program, delegate: self)
        self.preloader = preloader
    }
    
    private var session: ProgramSession? {
        get {
            return sessionManager.session
        }
    }
    
    public let settings = UserDefaults.init()
    
    public var state = State.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: state.rawValue)
            stateListener?.onStateChanged(state: state)
        }
    }
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
    
    public func applicationDidBecomeActive() {
        if let existingToken = self.savedToken {
            self.sessionManager.resumeSession(existingToken: existingToken)
        } else {
            self.sessionManager.newSession()
        }
    }

    func applicationWillResignActive() {
        extoleInfo(format: "application resign active")
        self.state = .Inactive
    }
    
}

extension ExtoleApp: SessionManagerDelegate {
    
    public func reload(complete: @escaping () -> Void) {
        if let session = self.session {
            session.getToken(success: { token in
                
            }) { error in
                complete()
            }
        }
    }
    
    public func serverError(error: ExtoleError) {
        
    }
    
    public func onSessionInvalid() {
        state = .InvalidToken
        self.sessionManager.newSession()
    }
    
    public func onSessionDeleted() {
        state = .LoggedOut
        self.sessionManager?.newSession()
    }
    
    public func onNewSession(session: ProgramSession) {
        state = .Identify
        self.savedToken = session.accessToken
        preloader.load(session: session, complete: {
            self.state = .ReadyToShare
        })
    }
}

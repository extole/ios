//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ExtoleAppObserver : class {
    func changed(state: ExtoleApp.State)
}

open class ExtoleApp {
    
    public enum State {
        case Init
        case Loading
        case Ready
    }
    
    private let program: Program

    public private(set) var sessionManager: SessionManager!
    private var preloader: Loader!
    
    private weak var observer: ExtoleAppObserver?
    
    init(with program: Program) {
        self.program = program
    }
    
    func initSessionManager(preloader: Loader, observer: ExtoleAppObserver) {
        self.sessionManager = SessionManager.init(program: self.program, delegate: self)
        self.preloader = preloader
        self.observer = observer
    }
    
    public convenience init(program: Program, preloader: Loader, observer: ExtoleAppObserver) {
        self.init(with: program)
        self.initSessionManager(preloader: preloader, observer: observer)
    }
    
    public let settings = UserDefaults.init()
    
    public var state = State.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: String(describing: state))
            observer?.changed(state: state)
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
            state = .Loading
            session.getToken(success: { token in
                self.preloader.load(session: session, complete: {
                    self.state = .Ready
                })
            }) { error in
                complete()
            }
        }
    }
    
    public func serverError(error: ExtoleError) {
        
    }
    
    public func onSessionInvalid() {
        state = .Init
        self.sessionManager.newSession()
    }
    
    public func onSessionDeleted() {
        state = .Init
        self.sessionManager?.newSession()
    }
    
    public func onNewSession(session: ProgramSession) {
        state = .Loading
        self.savedToken = session.accessToken
        preloader.load(session: session, complete: {
            self.state = .Ready
        })
    }
}

extension ExtoleApp {
}

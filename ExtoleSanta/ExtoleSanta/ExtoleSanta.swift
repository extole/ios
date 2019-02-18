//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleKit

public protocol ExtoleAppStateListener : class {
    func onStateChanged(state: ExtoleSanta.State)
}

public final class ExtoleSanta {

    public enum State : String {
        case Init = "Init"
        case LoggedOut = "LoggedOut"
        case Inactive = "Inactive"
        case InvalidToken = "InvalidToken"
        case ServerError = "ServerError"
        
        case Identify = "Identify"
        case Identified = "Identified"
        
        case ReadyToShare = "ReadyToShare"
    }
    
    private let program: Program
    
    public private(set) var sessionManager: SessionManager!
    public private(set) var profileManager: ProfileManager?
    public private(set) var shareableManager: ShareableManager?
    
    public weak var stateListener: ExtoleAppStateListener?

    convenience init(programUrl: URL) {
        self.init(with: programUrl)
        sessionManager = SessionManager.init(program: self.program, delegate: self)
    }

    private init(with programUrl: URL) {
        self.program = Program.init(baseUrl: programUrl)
    }

    public var session: ProgramSession? {
        get {
            return sessionManager.session
        }
    }
    
    private let label = "refer-a-friend"
    
    public let settings = UserDefaults.init()
    
    public var state = State.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: state.rawValue)
            stateListener?.onStateChanged(state: state)
        }
    }
    
    private let dispatchQueue = DispatchQueue(label : "Extole", qos:.background)
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
    
    var savedShareableCode : String? {
        get {
            return settings.string(forKey: "extole.shareable_code")
        }
        set(newShareableKey) {
            settings.set(newShareableKey, forKey: "extole.shareable_code")
        }
    }
    
    func applicationDidBecomeActive() {
        if let existingToken = self.savedToken {
            self.sessionManager.resumeSession(existingToken: existingToken)
        } else {
            self.sessionManager.newSession()
        }
    }
    
    private func onServerError() {
        self.state = State.ServerError
    }
    
    public func signalShare(channel: String) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        let share = CustomShare.init(advocate_code: self.shareableManager!.selectedShareable!.code!, channel: channel)
        self.session!.customShare(share: share, success: { pollingResponse in
            self.session!.pollCustomShare(pollingResponse: pollingResponse!, success: { shareResponse in
                self.state = State.ReadyToShare
            }, error: { _ in
                
            })
        }, error: { _ in
            
        })
    }
    
    public func share(email: String) {
        extoleInfo(format: "sharing to email %s", arg: email)
        let share = EmailShare.init(advocate_code: self.shareableManager!.selectedShareable!.code!,
                                     recipient_email: email)
        self.session!.emailShare(share: share, success: { pollingResponse in
            self.session!.pollEmailShare(pollingResponse: pollingResponse!, success: { shareResponse in
                self.state = State.ReadyToShare
            }, error: { _ in
                
            })
        }, error: { _ in
            
        })
    }
    
    func applicationWillResignActive() {
        extoleInfo(format: "application resign active")
        self.state = .Inactive
    }
}

extension ExtoleSanta: SessionManagerDelegate {
    public func tokenInvalid() {
        state = .InvalidToken
        self.sessionManager.newSession()
    }
    
    public func tokenDeleted() {
        state = .LoggedOut
        self.sessionManager.newSession()
    }
    
    public func tokenVerified(token: ConsumerToken) {
        state = .Identify
        self.savedToken = token.accessToken
        profileManager = ProfileManager.init(session: self.session!, delegate: self)
        profileManager?.load()
    }
    
    public func serverError(error: GetTokenError) {
        
    }
}

extension ExtoleSanta: ProfileManagerDelegate {
    public func loaded(profile: MyProfile) {
        if profile.email?.isEmpty ?? true {
            self.state = .Identify
        } else {
            self.state = .Identified
        }
        shareableManager = ShareableManager.init(session: self.session!,
                                                 delegate: self)
        shareableManager?.load()
    }
}

extension ExtoleSanta: ShareableManagerDelegate {

    public func error(error: GetShareablesError?) {
    }

    public func created(code: String?) {
        self.savedShareableCode = code
        shareableManager?.load()
    }

    public func loaded(shareables: [MyShareable]?) {
        if let savedCode = self.savedShareableCode {
            shareableManager?.select(code: savedCode)
        } else {
            let uniqueKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label, key: uniqueKey)
            shareableManager?.new(shareable: newShareable)
        }
    }

    public func selected(shareable: MyShareable?) {
        self.savedShareableCode = shareableManager?.selectedShareable?.code
        self.state = .ReadyToShare
    }
}

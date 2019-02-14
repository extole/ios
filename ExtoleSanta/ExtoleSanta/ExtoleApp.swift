//Copyright © 2019 Extole. All rights reserved.


import Foundation
import ExtoleKit

public protocol ExtoleAppStateListener : AnyObject {
    func onStateChanged(state: ExtoleApp.State)
}

public final class ExtoleApp: SessionStateListener, ProfileStateListener, ShareableStateListener {
    public func onStateChanged(state: ShareableState) {
        switch state {
        case .Selected:
            self.savedShareableKey = shareableManager?.selectedShareable?.key
            self.state = .ReadyToShare
        default:
            break
        }
    }
    
    public func onStateChanged(state: ProfileState) {
        switch state {
        case .Identified:
            self.state = .Identified
            shareableManager = ShareableManager.init(session: self.session!,
                                                     label: self.label,
                                                     shareableKey: self.savedShareableKey,
                                                     listener: self)
            shareableManager?.load()
        default:
            self.state = .Identify
        }
    }

    public func onStateChanged(state: SessionState) {
        switch state {
        case .Verified(let token):
            self.savedToken = token.access_token
            profileManager = ProfileManager.init(session: self.session!, listener: self)
            profileManager?.load()
            break
        default:
            break
        }
    }

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
    
    public var session: ProgramSession? {
        get {
            return sessionManager.session
        }
    }
    
    lazy public private(set) var sessionManager: SessionManager = {
        return SessionManager.init(program: self.program, listener: self)
    }()
    
    public private(set) var profileManager: ProfileManager?
    public private(set) var shareableManager: ShareableManager?
    
    public weak var stateListener: ExtoleAppStateListener?
    
    public init(programUrl: URL, stateListener: ExtoleAppStateListener? = nil) {
        self.program = Program.init(baseUrl: programUrl)
        self.sessionManager = SessionManager.init(program: self.program, listener: self)
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
    
    var savedShareableKey : String? {
        get {
            return settings.string(forKey: "extole.shareable_key")
        }
        set(newShareableKey) {
            settings.set(newShareableKey, forKey: "extole.shareable_key")
        }
    }
    
    public func applicationDidBecomeActive() {
        // SFSafariViewController - to restore session
        extoleInfo(format: "applicationDidBecomeActive")
        dispatchQueue.async {
            if let existingToken = self.savedToken {
                self.sessionManager.activate(existingToken: existingToken)
            } else {
                self.sessionManager.newSession()
                
            }
        }
    }
    
    private func onServerError() {
        self.state = State.ServerError
    }
    
    public func signalShare(channel: String) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        let share = CustomShare.init(advocate_code: self.shareableManager!.selectedShareable!.code!, channel: channel)
        self.session!.customShare(share: share) { pollingResponse, error in

            self.session!.pollCustomShare(pollingResponse: pollingResponse!) { shareResponse, error in
                self.state = State.ReadyToShare
                //self.lastShareResult = shareResponse
            }
        }
    }
    
    public func share(email: String) {
        extoleInfo(format: "sharing to email %s", arg: email)
        let share = EmailShare.init(advocate_code: self.shareableManager!.selectedShareable!.code!,
                                     recipient_email: email)
        self.session!.emailShare(share: share) { pollingResponse, error in
            if let pollingResponse = pollingResponse {
                self.session!.pollEmailShare(pollingResponse: pollingResponse) { shareResponse, error in
                    self.state = State.ReadyToShare
                    //self.lastShareResult = shareResponse
                }
            }
        }
    }
    
    
    
    public func applicationWillResignActive() {
        extoleInfo(format: "application resign active")
        self.state = .Inactive
    }
}

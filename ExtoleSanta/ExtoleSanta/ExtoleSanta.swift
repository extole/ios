//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleKit

public protocol ExtoleAppStateListener : AnyObject {
    func onStateChanged(state: ExtoleSanta.State)
}

public final class ExtoleSanta: ProfileStateListener, ShareableStateListener {
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
    
    var savedShareableKey : String? {
        get {
            return settings.string(forKey: "extole.shareable_key")
        }
        set(newShareableKey) {
            settings.set(newShareableKey, forKey: "extole.shareable_key")
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
        profileManager = ProfileManager.init(session: self.session!, listener: self)
        profileManager?.load()
    }
    
    public func serverError(error: GetTokenError) {
        
    }
}

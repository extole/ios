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
    
    private(set) var sessionManager: SessionManager?
    
    private(set) var profileLoader: ProfileLoader?
    private(set) var shareableLoader: ShareableLoader?
    private(set) var settingsLoader: ZoneLoader<ShareSettings>?
    
    public weak var stateListener: ExtoleAppStateListener?

    convenience init(programUrl: URL) {
        self.init(with: programUrl)
    }

    private init(with programUrl: URL) {
        self.program = Program.init(baseUrl: programUrl)
    }

    public var session: ProgramSession? {
        get {
            return sessionManager?.session
        }
    }
    
    public var selectedShareable: MyShareable? {
        get {
            return shareableLoader?.shareables?.filter({ shareable in
                shareable.code == selectedShareableCode
            }).first
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
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
    
    var selectedShareableCode : String? {
        get {
            return settings.string(forKey: "extole.shareable_code")
        }
        set(newShareableKey) {
            settings.set(newShareableKey, forKey: "extole.shareable_code")
        }
    }
    
    func applicationDidBecomeActive() {
        sessionManager = SessionManager.init(program: self.program, delegate: self)
        if let existingToken = self.savedToken {
            self.sessionManager!.resumeSession(existingToken: existingToken)
        } else {
            self.sessionManager!.newSession()
        }
    }
    
    public func signalShare(channel: String) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        if let shareableCode = selectedShareableCode {
            let share = CustomShare.init(advocate_code: shareableCode, channel: channel)
            self.session!.customShare(share: share, success: { pollingResponse in
                self.session!.pollCustomShare(pollingResponse: pollingResponse!, success: { shareResponse in
                    self.state = State.ReadyToShare
                }, error: { _ in
                    
                })
            }, error: { _ in
                
            })
        }
    }
    
    public func share(email: String) {
        extoleInfo(format: "sharing to email %s", arg: email)
        if let shareableCode = selectedShareableCode {
            let share = EmailShare.init(advocate_code: shareableCode,
                                         recipient_email: email)
            self.session!.emailShare(share: share, success: { pollingResponse in
                self.session!.pollEmailShare(pollingResponse: pollingResponse!, success: { shareResponse in
                    self.state = State.ReadyToShare
                }, error: { _ in
                    
                })
            }, error: { _ in
                
            })
        }
    }
    
    func applicationWillResignActive() {
        extoleInfo(format: "application resign active")
        self.state = .Inactive
    }
}

extension ExtoleSanta: SessionManagerDelegate {
    public func serverError(error: ExtoleError) {
        
    }
    
    public func onSessionInvalid() {
        state = .InvalidToken
        self.sessionManager?.newSession()
    }
    
    public func onSessionDeleted() {
        state = .LoggedOut
        self.sessionManager?.newSession()
    }
    
    public func onNewSession(session: ProgramSession) {
        state = .Identify
        self.savedToken = session.accessToken
        profileLoader = ProfileLoader.init(session: session)
        profileLoader?.load() { profile in
            if profile.email?.isEmpty ?? true {
                self.state = .Identify
            } else {
                self.state = .Identified
            }
        }
        
        settingsLoader = ZoneLoader.init(session: session, zoneName: "settings")
        settingsLoader?.load()
        
        shareableLoader = ShareableLoader.init(session: session)
        shareableLoader?.load(success: shareablesLoaded)
    }
    
    func shareablesLoaded(shareables: [MyShareable]?) {
        if let shareable = self.selectedShareable {
            extoleInfo(format: "re-using previosly selected shareable %s", arg: shareable.code)
        } else {
            self.selectedShareableCode = nil
            let uniqueKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label, key: uniqueKey)
            session?.createShareable(shareable: newShareable, success: { pollingId in
                self.session?.pollShareable(pollingResponse: pollingId!,
                                            success: { shareableResult in
                                                self.selectedShareableCode = shareableResult?.code
                                                self.shareableLoader?.load(success: self.shareablesLoaded)
                }, error: {_ in
                    
                })
            }, error : { _ in
                
            })
        }
    }
    
}

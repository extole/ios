//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleKit

public protocol ExtoleSantaStateListener : class {
    func onStateChanged(state: ExtoleSanta.State)
}

public final class ExtoleSanta {

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
    
    var sessionManager : SessionManager? {
        get {
            return extoleApp?.sessionManager
        }
    }
    
    private (set) var extoleApp : ExtoleApp?
    
    private(set) var profileLoader: ProfileLoader?
    private(set) var shareableLoader: ShareableLoader?
    private(set) var settingsLoader: ZoneLoader<ShareSettings>?
    
    public weak var stateListener: ExtoleSantaStateListener?

    convenience init(programUrl: URL) {
        self.init(with: programUrl)
    }

    private init(with programUrl: URL) {
        self.program = Program.init(baseUrl: programUrl)
    }
    
    private var session: ProgramSession? {
        get {
            return sessionManager?.session
        }
    }
    
    public var selectedShareable: MyShareable? {
        get {
            return shareableLoader?.shareables?.filter({ shareable in
                shareable.code == extoleApp?.selectedShareableCode
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
    
    func applicationDidBecomeActive() {
        
        profileLoader = ProfileLoader() { profile in
            if profile.email?.isEmpty ?? true {
                self.state = .Identify
            } else {
                self.state = .Identified
            }
        }
        
        settingsLoader = ZoneLoader(zoneName: "settings")
        shareableLoader = ShareableLoader(success: shareablesLoaded)
        
        let composite = CompositeLoader(loaders: [profileLoader!, settingsLoader!, shareableLoader!])

        extoleApp = ExtoleApp(program: self.program, preloader: composite, observer: self)
        extoleApp!.applicationDidBecomeActive()
    }
    
    public func signalShare(channel: String) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        if let shareableCode = extoleApp?.selectedShareableCode {
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
        if let shareableCode = extoleApp?.selectedShareableCode {
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
    
    public func reload(complete: @escaping () -> Void) {
        extoleApp?.reload(complete: complete)
    }
    
    func shareablesLoaded(shareables: [MyShareable]?) {
        if let shareable = self.selectedShareable {
            extoleInfo(format: "re-using previosly selected shareable %s", arg: shareable.code)
        } else {
            self.extoleApp?.selectedShareableCode = nil
            let uniqueKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label, key: uniqueKey)
            session?.createShareable(shareable: newShareable, success: { pollingId in
                self.session?.pollShareable(pollingResponse: pollingId!,
                                            success: { shareableResult in
                                                self.extoleApp?.selectedShareableCode = shareableResult?.code
                                                self.shareableLoader?.load(session: self.session!){}
                }, error: {_ in
                    
                })
            }, error : { _ in
                
            })
        }
    }
}

extension ExtoleSanta {
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (UpdateProfileError) -> Void) {
        session?.updateProfile(profile: profile, success: success, error: error)
    }
}
extension ExtoleSanta : ExtoleAppObserver {
    public func changed(state: ExtoleApp.State) {
        switch state {
        case .Ready:
            self.state = .ReadyToShare
        default:
            self.state = .Loading
        }
    }
}

//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ExtoleShareAppDelegate : class {
    func load()
    func ready()
}

public final class ExtoleShareApp : ExtoleAppDelegate {
    public func activate() {
        extoleApp.activate()
    }
    
    public func reset() {
        selectedShareableCode = nil
        extoleApp.reset()
    }

    public func invalidate() {
        session = nil
    }

    public func load(session: ProgramSession) {
        self.session = session
        preloader.load(session: session){
            self.delegate?.ready()
        }
    }
    
    public var selectedShareableCode : String? {
        get {
            return extoleApp.settings.string(forKey: "shareable_code")
        }
        set(newShareableKey) {
            extoleApp.settings.set(newShareableKey, forKey: "shareable_code")
        }
    }

    private var extoleApp: ExtoleApp!
    public private(set) var session: ProgramSession?
    private weak var delegate: ExtoleShareAppDelegate?
    
    public private(set) var profileLoader: ProfileLoader!
    public private(set) var shareableLoader: ShareableLoader!
    public private(set) var settingsLoader: ZoneLoader<ShareSettings>!
    let label : String
    
    private var preloader: Loader!
    
    public init(programUrl: URL, label: String, delegate: ExtoleShareAppDelegate?) {
        self.label = label
        self.extoleApp = ExtoleApp(program: Program(baseUrl: programUrl), delegate: self)
        self.delegate = delegate
        
        profileLoader = ProfileLoader() { _ in
        }
        
        settingsLoader = ZoneLoader(zoneName: "settings")
        shareableLoader = ShareableLoader(success: shareablesLoaded)
        
        self.preloader = CompositeLoader(loaders: [profileLoader!, settingsLoader!, shareableLoader!])
    }
    
    public func reload(complete: @escaping () -> Void) {
        if let session = session {
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
    
    public func signalShare(channel: String,
                            success: @escaping (CustomSharePollingResult?)->Void,
                            error: @escaping(ExtoleError) -> Void) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        
        if let session = session, let shareableCode = selectedShareableCode{
            let share = CustomShare.init(advocate_code: shareableCode, channel: channel)
            session.customShare(share: share, success: { pollingResponse in
                session.pollCustomShare(pollingResponse: pollingResponse!,
                                        success: success, error: error)
            }, error: error)
        }
    }
    
    public func share(email: String,
                      success: @escaping (EmailSharePollingResult?)->Void,
                      error: @escaping(ExtoleError) -> Void) {
        extoleInfo(format: "sharing to email %s", arg: email)
        if let session = session, let shareableCode = selectedShareableCode {
            let share = EmailShare.init(advocate_code: shareableCode,
                                        recipient_email: email)
            session.emailShare(share: share, success: { pollingResponse in
                session.pollEmailShare(pollingResponse: pollingResponse!,success:success, error: error)
            }, error: error)
        }
    }
    
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (UpdateProfileError) -> Void) {
        session?.updateProfile(profile: profile, success: success, error: error)
    }
    
    public var selectedShareable: MyShareable? {
        get {
            return shareableLoader?.shareables?.filter({ shareable in
                shareable.code == self.selectedShareableCode
            }).first
        }
    }
    
    func shareablesLoaded(shareables: [MyShareable]?) {
        if let shareable = self.selectedShareable {
            extoleInfo(format: "re-using previosly selected shareable %s", arg: shareable.code)
        } else {
            self.selectedShareableCode = nil
            let uniqueKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label, key: uniqueKey)
            self.session?.createShareable(shareable: newShareable, success: { pollingId in
                self.session?.pollShareable(pollingResponse: pollingId!,
                                            success: { shareableResult in
                                                self.selectedShareableCode = shareableResult?.code
                                                self.shareableLoader?.load(session: self.session!){}
                }, error: {_ in
                    
                })
            }, error : { _ in
                
            })
        }
    }
}

public struct ShareSettings : Codable {
    public let shareMessage: String
}

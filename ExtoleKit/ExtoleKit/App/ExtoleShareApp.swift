//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles events for ExtoleShareApp
public protocol ExtoleShareAppDelegate : class {
    /// signals ExtoleShareApp is busy
    func extoleShareAppBusy()
    /// signals ExtoleShareApp is ready
    func extoleShareAppReady()
}


/// High level API for Extole Share Experience
public final class ExtoleShareApp {
    /// Underlying Extole app
    private var extoleApp: ExtoleApp!
    /// Share Experience event handler
    private weak var delegate: ExtoleShareAppDelegate?
    /// Extole program label
    private let label : String
    /// Composite preloader to load profile, shareables, and settings at once
    private var preloader: CompositeLoader!
    
    /// Active consumer session
    public private(set) var session: ConsumerSession?
    /// Loads consumer shareables
    public private(set) var shareableLoader: ShareableLoader!

    /// Creates new Extole share experince
    public init(programUrl: URL, programLabel label: String, delegate: ExtoleShareAppDelegate?,
                extraLoaders: [Loader]) {
        self.label = label
        self.extoleApp = ExtoleApp(with: ProgramURL(baseUrl: programUrl), delegate: self)
        self.delegate = delegate
        
        shareableLoader = ShareableLoader(delegate: self)
        
        var loaders = [Loader]()
        loaders.append(shareableLoader)
        loaders.append(contentsOf: extraLoaders)
        
        self.preloader = CompositeLoader(loaders: loaders)
    }
    /// Activate will resume Extole session, and prepare for sharing
    public func activate() {
        extoleApp.activate()
    }

    /// Cleans current Extole session, and share resources
    public func reset() {
        selectedShareableCode = nil
        extoleApp.reset()
    }

    /// Shareable code used in this share session
    public var selectedShareableCode : String? {
        get {
            return extoleApp.settings.string(forKey: "shareable_code")
        }
        set(newShareableKey) {
            extoleApp.settings.set(newShareableKey, forKey: "shareable_code")
        }
    }

    /// reloads share experince, within the same consumer session
    public func reload(complete: @escaping () -> Void) {
        if let session = session {
            session.getToken(success: { token in
                self.delegate?.extoleShareAppBusy()
                self.preloader?.load(session: session, complete: {
                    self.delegate?.extoleShareAppReady()
                })
            }) { error in
                complete()
            }
        }
    }

    /// Sends custom share event to Extole
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

    /// Sends a share to given email, using Extole email service
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
    
    /// Updates consumer profile
    public func updateProfile(profile: MyProfile,
                              success: @escaping () -> Void,
                              error : @escaping (UpdateProfileError) -> Void) {
        session?.updateProfile(profile: profile, success: success, error: error)
    }
    
    /// Shareable used for current consumer session
    public var selectedShareable: MyShareable? {
        get {
            return shareableLoader?.shareables?.filter({ shareable in
                shareable.code == self.selectedShareableCode
            }).first
        }
    }
}

extension ExtoleShareApp : ShareableLoaderDelegate {
    public func success(shareables: [MyShareable]?) {
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
extension ExtoleShareApp : ExtoleAppDelegate {
    public func extoleAppInvalid() {
        session = nil
    }
    
    public func extoleAppReady(session: ConsumerSession) {
        self.session = session
        preloader.load(session: session){
            self.delegate?.extoleShareAppReady()
        }
    }
    
    public func extoleAppError(error: ExtoleError) {
        
    }
    
    
}



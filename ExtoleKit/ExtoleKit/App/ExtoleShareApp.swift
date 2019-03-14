//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Handles events for ExtoleShareApp
@objc public protocol ExtoleShareAppDelegate : class {
    /// signals ExtoleShareApp is busy
    func extoleShareAppInvalid()
    /// signals ExtoleShareApp is ready
    func extoleShareAppReady(shareApp: ExtoleShareApp)
}

/// High level API for Extole Share Experience
public final class ExtoleShareApp : NSObject {

    /// Underlying Extole app
    private var extoleApp: ExtoleApp!
    /// Share Experience event handler
    private weak var delegate: ExtoleShareAppDelegate?
    /// Extole program label
    private let label : String
    /// Composite preloader to load profile, shareables, and settings at once
    private var preloader: CompositeLoader!
    /// Active consumer session
    @objc public private(set) var session: ConsumerSession?
    /// Loads consumer shareables
    public private(set) var shareableLoader: ShareableLoader!

    /// Creates new Extole share experince
    @objc public init(programUrl: URL,
                programLabel label: String,
                delegate: ExtoleShareAppDelegate?,
                extraLoaders: [Loader] = [],
                network: Network = Network()) {
        self.label = label
        super.init()
        
        self.extoleApp = ExtoleApp(with: ProgramURL(baseUrl: programUrl, network: network), delegate: self)
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
        savedShareableCode = nil
        extoleApp.reset()
    }

    /// Shareable code used in this share session
    private var savedShareableCode : String? {
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
                self.preloader?.load(session: session, complete: {
                    complete()
                })
            }) { error in
                complete()
                self.extoleApp.onSessionServerError(error: error)
            }
        }
    }

    /// Sends custom share event to Extole
    public func notify(share: CustomShare,
                        success: @escaping (CustomSharePollingResult)->Void,
                        error: @escaping(ExtoleError) -> Void) {
        extoleInfo(format: "shared via custom channel %s", arg: share.channel)
        
        if let session = session, let shareableCode = selectedShareable?.code {
            share.advocate_code = shareableCode
            session.customShare(share: share, success: { pollingResponse in
                session.pollCustomShare(pollingResponse: pollingResponse,
                                        success: success, error: error)
            }, error: error)
        } else {
            error(ExtoleError.init(code: "not_ready"))
        }
    }

    /// Sends a share to given email, using Extole email service
    public func send(share: EmailShare,
                      success: @escaping (EmailSharePollingResult)->Void,
                      error: @escaping(ExtoleError) -> Void) {
        extoleInfo(format: "sharing to email %s", arg: share.recipient_email)
        if let session = session, let shareableCode = selectedShareable?.code {
            share.advocate_code = shareableCode
            session.emailShare(share: share, success: { pollingResponse in
                session.pollEmailShare(pollingResponse: pollingResponse!,success:success, error: error)
            }, error: error)
        }
    }
    
   
    
    /// Shareable used for current consumer session
    public var selectedShareable: MyShareable? {
        get {
            return shareableLoader?.shareables?.filter({ shareable in
                shareable.code == self.savedShareableCode
            }).first
        }
    }
}

extension ExtoleShareApp : ShareableLoaderDelegate {
    public func success(shareables: [MyShareable],  complete: @escaping () -> Void) {
        if let shareable = self.selectedShareable {
            extoleInfo(format: "re-using previosly selected shareable %s", arg: shareable.code)
            complete()
        } else {
            self.savedShareableCode = nil
            let uniqueKey = NSUUID().uuidString
            let newShareable = MyShareable.init(label: self.label, key: uniqueKey)
            self.session?.createShareable(shareable: newShareable, success: { pollingId in
                self.session?.pollShareable(pollingResponse: pollingId,
                                            success: { shareableResult in
                                                self.savedShareableCode = shareableResult.code
                                                self.shareableLoader?.load(session: self.session!, complete: complete)
                }, error: {_ in
                    
                })
            }, error : { _ in
                
            })
        }
    }
}

extension ExtoleShareApp : ExtoleAppDelegate {
    public func extoleAppInvalid() {
        self.delegate?.extoleShareAppInvalid()
        session = nil
        
    }

    public func extoleAppReady(session: ConsumerSession) {
        self.session = session
        preloader.load(session: session) {
            self.delegate?.extoleShareAppReady(shareApp: self)
        }
    }
}

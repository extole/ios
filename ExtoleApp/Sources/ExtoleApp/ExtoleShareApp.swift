//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

/// Handles events for ExtoleShareApp
public protocol ExtoleShareAppDelegate : class {
    /// signals ExtoleShareApp is busy
    func extoleShareAppInvalid()
    /// signals ExtoleShareApp is ready
    func extoleShareAppReady(shareApp: ExtoleShareApp)
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
    public private(set) var session: ExtoleAPI.Session?
    
    public var mobileSharing: MobileSharing? {
        get {
            return mobileShareLoader.mobileSharing
        }
    }
    
    private let mobileShareLoader = MobileSharingLoader()
    
    /// Creates new Extole share experince
    public init(programDomain: String,
                programLabel label: String,
                delegate: ExtoleShareAppDelegate?,
                extraLoaders: [Loader] = [],
                network: Network = Network()) {
        self.label = label
        
        self.extoleApp = ExtoleApp(with: ExtoleAPI(programDomain: programDomain, network: network), delegate: self)
        self.delegate = delegate
        
        var loaders : [Loader] = [mobileShareLoader]
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
            session.verify(success: { token in
                self.preloader?.load(session: session, complete: {
                    complete()
                })
            }) { error in
                complete()
                self.extoleApp.onSessionServerError(error: error)
            }
        }
    }
}

extension ExtoleShareApp : ExtoleAppDelegate {
    public func extoleAppInvalid() {
        self.delegate?.extoleShareAppInvalid()
        session = nil
        
    }

    public func extoleAppReady(session: ExtoleAPI.Session) {
        self.session = session
        preloader.load(session: session) {
            self.delegate?.extoleShareAppReady(shareApp: self)
        }
    }
}

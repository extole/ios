//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI


/// Handles events for ExtoleShareApp
public protocol ShareAppAppDelegate : class {
    /// signals ExtoleShareApp is busy
    func extoleShareAppInvalid()
    /// signals ExtoleShareApp is ready
    func extoleShareAppReady(shareApp: ExtoleApp.ShareApp)
}


extension ExtoleApp {

/// High level API for Extole Share Experience
public final class ShareApp {
    public typealias Delegate = ShareAppAppDelegate
    /// Underlying Extole app
    private var extoleApp: ExtoleApp!
    /// Share Experience event handler
    private weak var delegate: ShareAppAppDelegate?
    /// Extole program label
    private let label : String
    /// Composite preloader to load profile, shareables, and settings at once
    private var preloader: CompositeLoader!
    /// Active consumer session
    public private(set) var session: ExtoleAPI.Session?
    
    public var mobileSharing: AdvocateMobileExperience? {
        get {
            return mobileShareLoader.mobileSharing
        }
    }
    
    public var selectedShareable: ExtoleAPI.Me.MeShareableResponse {
        get {
            return selectedShareableLoader.shareables[0]
        }
    }
    
    public var sessionManager: SessionManager {
        get {
            return extoleApp.sessionManager
        }
    }
    
    private let mobileShareLoader = AdvocateMobileExperienceLoader(data: [:])
    private let selectedShareableLoader = ShareableLoader()
    
    /// Creates new Extole share experince
    public init(programDomain: String,
                programLabel label: String,
                delegate: ShareAppAppDelegate?,
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
}}

extension ExtoleApp.ShareApp : ExtoleAppDelegate {
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



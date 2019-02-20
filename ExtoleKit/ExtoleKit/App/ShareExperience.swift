//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ShareExperince {
    /// Activate will resume Extole session, and prepare for sharing
    func activate()
    
    /// Cleans current Extole session, and share resources
    func reset()
    
    /// Shareable code used in this share session
    var selectedShareableCode : String? {
        get
    }
    /// reloads share experince, within the same consumer session
    func reload(complete: @escaping () -> Void)
    
    /// Sends custom share event to Extole
    func signalShare(channel: String,
                     success: @escaping (CustomSharePollingResult?)->Void,
                     error: @escaping(ExtoleError) -> Void)
    
    /// Sends a share to given email, using Extole email service
    func share(email: String,
               success: @escaping (EmailSharePollingResult?)->Void,
               error: @escaping(ExtoleError) -> Void)
    
    /// Shareable used for current consumer session
    var selectedShareable: MyShareable? {
        get
    }
    
    var shareApp : ExtoleShareApp {
        get
    }
}

public extension ShareExperince {
    func activate() {
        shareApp.activate()
    }
    var session : ConsumerSession? {
        get {
            return shareApp.session
        }
    }
    
    var profile: MyProfile? {
        get {
            return shareApp.profileLoader.profile
        }
    }
    var selectedShareable: MyShareable? {
        get {
            return shareApp.selectedShareable
        }
    }
    var shareSettings : ShareSettings? {
        get {
            return shareApp.settingsLoader.zoneData
        }
    }
    
    func reset() {
        shareApp.reset()
    }
    
    func reload(complete: @escaping () -> Void) {
        shareApp.reload(complete: complete)
    }
    
    public func signalShare(channel: String,
                            success: @escaping (CustomSharePollingResult?)->Void,
                            error: @escaping(ExtoleError) -> Void) {
        shareApp.signalShare(channel: channel, success: success, error: error)
    }
    
    public func share(email: String,
                      success: @escaping (EmailSharePollingResult?)->Void,
                      error: @escaping(ExtoleError) -> Void) {
        shareApp.share(email: email, success: success, error: error)
    }
    
    public var selectedShareableCode: String? {
        get {
            return shareApp.selectedShareableCode
        }
    }
}

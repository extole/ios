//Copyright © 2019 Extole. All rights reserved.

import Foundation

/// Describes Extole share experience
public protocol ShareExperience {
    /// Activate will resume Extole session, and prepare for sharing
    func activate()
    
    /// Cleans current Extole session, and share resources
    func reset()
    
    /// reloads share experince, within the same consumer session
    func reload(complete: @escaping () -> Void)
    
    /// Sends custom share event to Extole
    func signal(share: CustomShare,
                 success: @escaping (CustomSharePollingResult)->Void,
                 error: @escaping(ExtoleError) -> Void)
    
    /// Sends a share to given email, using Extole email service
    func share(share: EmailShare,
               success: @escaping (EmailSharePollingResult)->Void,
               error: @escaping(ExtoleError) -> Void)
    
    /// Shareable used for current consumer session
    var selectedShareable: MyShareable? {
        get
    }
    
    var session: ConsumerSession? {
        get
    }
    
    
}

@objc public protocol HasShareApp {
    var shareApp : ExtoleShareApp {
        get
    }
}

public protocol DefaultShareExperince : ShareExperience{
    
}

public extension DefaultShareExperince where Self: HasShareApp {
    func activate() {
        shareApp.activate()
    }

    var session : ConsumerSession? {
        get {
            return shareApp.session
        }
    }
    
    var selectedShareable: MyShareable? {
        get {
            return shareApp.selectedShareable
        }
    }

    func reset() {
        shareApp.reset()
    }
    
    func reload(complete: @escaping () -> Void) {
        shareApp.reload(complete: complete)
    }
    
    public func signal(share: CustomShare,
                            success: @escaping (CustomSharePollingResult)->Void,
                            error: @escaping(ExtoleError) -> Void) {
        shareApp.enque { app in
            app.signal(share: share, success: success, error: error)
        }
    }

    public func share(share: EmailShare,
                      success: @escaping (EmailSharePollingResult)->Void,
                      error: @escaping(ExtoleError) -> Void) {
        shareApp.enque { app in
            app.share(share: share, success: success, error: error)
        }
    }
}

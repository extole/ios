//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public class SimpleShareExperince: NSObject, ShareExperience {
    public func activate() {
        self.shareApp.activate()
    }
    
    public func reload(complete: @escaping () -> Void) {
        self.shareApp.reload(complete: complete)
    }
    
    public var selectedShareable: MyShareable?
    
    public var session: ConsumerSession?
    
    public let shareApp: ExtoleShareApp
    let appDelegate = SimpleShareAppDelegate()
    
    @objc public init(programUrl: URL, programLabel: String) {
        self.shareApp = ExtoleShareApp.init(programUrl: programUrl, programLabel: programLabel, delegate: appDelegate)
    }

    @objc public func enque(command: @escaping (ExtoleShareApp) -> Void ) {
        shareApp.enque(command: command)
    }

    public func send(
        share: EmailShare,
        success: @escaping (EmailSharePollingResult) -> Void = { _ in },
        error: @escaping (ExtoleError) -> Void = { _ in }) {
        shareApp.enque { app in
            self.shareApp.send(share: share, success: success, error: error)
        }
    }
    
    @objc public func notify(
            share: CustomShare,
            success: @escaping (CustomSharePollingResult) -> Void = { _ in },
            error: @escaping (ExtoleError) -> Void = { _ in }) {
        shareApp.enque { app in
            app.notify(share: share, success: success, error: error)
        }
    }
    
    @objc public func reset() {
        shareApp.reset()
    }
    
    var isValid: Bool? {
        get {
            return appDelegate.isValid
        }
    }
}

class SimpleShareAppDelegate : ExtoleShareAppDelegate {

    var isValid : Bool?;
    
    func extoleShareAppInvalid() {
        isValid = false;
    }
    
    func extoleShareAppReady() {
         isValid = true;
    }
}

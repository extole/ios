//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public class SimpleShareExperince: NSObject {
    
    public let shareApp: ExtoleShareApp
    let appDelegate = SimpleShareAppDelegate()
    
    @objc public init(programUrl: URL, programLabel: String) {
        self.shareApp = ExtoleShareApp.init(programUrl: programUrl, programLabel: programLabel, delegate: appDelegate)
    }

    @objc public func enque(command: @escaping (ExtoleShareApp) -> Void ) {
        shareApp.enque(command: command)
    }

    @objc public func
        signal(
            share: CustomShare,
            success: @escaping (CustomSharePollingResult) -> Void = { _ in },
            error: @escaping (ExtoleError) -> Void = { _ in }) {
        shareApp.enque { app in
            app.signal(share: share, success: success, error: error)
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

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

    @objc public func signalShare(channel: String, success: @escaping (CustomSharePollingResult) -> Void, error: @escaping (ExtoleError) -> Void) {
        shareApp.enque { app in
            app.signalShare(channel: channel, success: success, error: error)
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

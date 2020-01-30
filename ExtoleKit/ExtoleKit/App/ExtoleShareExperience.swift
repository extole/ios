//Copyright © 2019 Extole. All rights reserved.

import Foundation

public class ExtoleShareExperince: NSObject {

    private var activated = false
    private let shareApp: ExtoleShareApp
    private let appDelegate = SimpleShareAppDelegate()
    
    public init(programDomain: String, programLabel: String) {
        self.shareApp = ExtoleShareApp.init(programDomain: programDomain, programLabel: programLabel, delegate: appDelegate)
    }
    
    public init(shareApp:  ExtoleShareApp) {
        self.shareApp = shareApp
    }
    
    @objc public func reset() {
        self.appDelegate.readyHandlers = []
        shareApp.reset()
    }

    ///
    public func async(command: @escaping (ExtoleShareApp?) -> Void ) {
        if !activated {
            shareApp.activate()
            activated = true
        }
        self.appDelegate.serialQueue.async {
            if (self.isValid) {
                command(self.shareApp)
            } else {
                self.appDelegate.readyHandlers.append(command)
            }
        }
    }
    
    public func fetchObject<T: Codable>(zone: String,
                                        data: [String: String] = [:],
                                        success:@escaping (T) -> Void,
                                        error : @escaping (ExtoleAPI.Error) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.renderZone(eventName: zone, data: data, success: success, error: error)
            } else {
                error(ExtoleAPI.Error(code: "reset"))
            }
        }
    }
    
    public func signal(zone: String,
                       data: [String :String]  = [:],
                       success:@escaping (ExtoleAPI.Events.SubmitEventResponse) -> Void,
                       error : @escaping (ExtoleAPI.Error) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.submitEvent(eventName: zone, data: data, success: success, error: error)
            } else {
                error(ExtoleAPI.Error(code: "reset"))
            }
        }
    }

    public func update(email: String? = nil,
                        first_name: String? = nil,
                        last_name: String? = nil,
                        profile_picture_url: String? = nil,
                        partner_user_id: String? = nil,
                             success: @escaping () -> Void = {},
                             error: @escaping (ExtoleAPI.Error) -> Void = { _ in }) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.updateProfile(email: email,
                                                first_name: first_name,
                                                last_name: last_name,
                                                profile_picture_url:    profile_picture_url,
                                                partner_user_id: partner_user_id,
                                                success:  success,
                                                error: error)
            } else {
                error(ExtoleAPI.Error.init(code: "reset"))
            }
        }
    }

    var isValid: Bool {
        get {
            return appDelegate.isReady
        }
    }
}

class SimpleShareAppDelegate : ExtoleShareAppDelegate {

    var readyHandlers : [(ExtoleShareApp?) -> Void] = []
    let serialQueue = DispatchQueue(label: "com.extole.ExtoleShareApp")
    var isReady = false
    
    func extoleShareAppInvalid() {
        self.serialQueue.async {
            let handlers = self.readyHandlers
            self.readyHandlers = []
            handlers.forEach { event in
                event(nil)
            }
        }
        isReady = false;
    }
    
    func extoleShareAppReady(shareApp: ExtoleShareApp) {
        isReady = true;
        self.serialQueue.async {
            let handlers = self.readyHandlers
            self.readyHandlers = []
            handlers.forEach { event in
                event(shareApp)
            }
        }
    }
}

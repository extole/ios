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
                                        parameters: [URLQueryItem]? = nil,
                                        success:@escaping (T) -> Void,
                                        error : @escaping (ExtoleAPI.Error) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.fetchObject(zone: zone, parameters: parameters, success: success, error: error)
            } else {
                error(ExtoleAPI.Error(code: "reset"))
            }
        }
    }

    
    public func notify(share: CustomShare,
                       success: @escaping (CustomSharePollingResult)->Void,
                       error: @escaping(ExtoleAPI.Error) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.notify(share: share, success: success, error: error)
            } else {
                error(ExtoleAPI.Error(code: "reset"))
            }
        }
    }
    
    public func signal(zone: String,
                             parameters: [URLQueryItem]? = nil,
                             success:@escaping () -> Void,
                             error : @escaping (ExtoleAPI.Error) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.signal(zone: zone, parameters: parameters, success: success, error: error)
            } else {
                error(ExtoleAPI.Error(code: "reset"))
            }
        }
    }

    public func update(profile: MyProfile,
                             success: @escaping () -> Void = {},
                             error: @escaping (ExtoleAPI.Error) -> Void = { _ in }) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.updateProfile(profile: profile, success: success, error: error)
            } else {
                error(ExtoleAPI.Error.init(code: "reset"))
            }
        }
    }
    
    public func fetchDictionary(zone: String,
                                      parameters: [URLQueryItem]?,
                                      success: @escaping (_: NSDictionary) -> Void,
                                      error : ExtoleApiErrorHandler) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.fetchDictionary(zone: zone, parameters: parameters, success: success, error: error)
            } else {
                error.genericError(errorData: ExtoleAPI.Error.init(code: "reset"))
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

//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public class ExtoleShareExperince: NSObject {

    private var activated = false
    private let shareApp: ExtoleShareApp
    private let appDelegate = SimpleShareAppDelegate()
    
    @objc public init(programUrl: URL, programLabel: String) {
        self.shareApp = ExtoleShareApp.init(programUrl: programUrl, programLabel: programLabel, delegate: appDelegate)
    }
    
    @objc public init(shareApp:  ExtoleShareApp) {
        self.shareApp = shareApp
    }
    
    @objc public func reset() {
        self.appDelegate.readyHandlers = []
        shareApp.reset()
    }

    ///
    @objc public func async(command: @escaping (ExtoleShareApp?) -> Void ) {
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
                                        error : @escaping (ExtoleError) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.fetchObject(zone: zone, parameters: parameters, success: success, error: error)
            } else {
                error(ExtoleError.init(code: "reset"))
            }
        }
    }

    
    @objc public func notify(share: CustomShare,
                       success: @escaping (CustomSharePollingResult)->Void,
                       error: @escaping(ExtoleError) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.notify(share: share, success: success, error: error)
            } else {
                error(ExtoleError.init(code: "reset"))
            }
        }
    }
    
    @objc public func signal(zone: String,
                             parameters: [URLQueryItem]? = nil,
                             success:@escaping () -> Void,
                             error : @escaping (ExtoleError) -> Void) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.signal(zone: zone, parameters: parameters, success: success, error: error)
            } else {
                error(ExtoleError.init(code: "reset"))
            }
        }
    }
    
    @objc public func fetchDictionary(zone: String,
                                      parameters: [URLQueryItem]?,
                                      success: @escaping (_: NSDictionary) -> Void,
                                      error : ExtoleApiErrorHandler) {
        self.async { (shareApp) in
            if let shareApp = shareApp {
                shareApp.session?.fetchDictionary(zone: zone, parameters: parameters, success: success, error: error)
            } else {
                error.genericError(errorData: ExtoleError.init(code: "reset"))
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

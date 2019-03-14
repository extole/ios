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

    @objc public func async(command: @escaping (ExtoleShareApp) -> Void ) {
        shareApp.async(command: command)
    }
    
    public func fetchObject<T: Codable>(zone: String,
                                        parameters: [URLQueryItem]? = nil,
                                        success:@escaping (T) -> Void,
                                        error : @escaping (ExtoleError) -> Void) {
        self.async { (shareApp) in
            shareApp.fetchObject(zone: zone, parameters: parameters, success: success, error: error)
        }
    }
    
    @objc public func fetchDictionary(zone: String,
                                      parameters: [URLQueryItem]?,
                                      success: @escaping (_: NSDictionary) -> Void,
                                      error : ExtoleApiErrorHandler) {
        self.async { (shareApp) in
            shareApp.fetchDictionary(zone: zone, parameters: parameters, success: success, error: error)
        }
    }

    public func send(
        share: EmailShare,
        success: @escaping (EmailSharePollingResult) -> Void = { _ in },
        error: @escaping (ExtoleError) -> Void = { _ in }) {
        shareApp.async { app in
            self.shareApp.send(share: share, success: success, error: error)
        }
    }
    
    @objc public func notify(
            share: CustomShare,
            success: @escaping (CustomSharePollingResult) -> Void = { _ in },
            error: @escaping (ExtoleError) -> Void = { _ in }) {
        shareApp.async { app in
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

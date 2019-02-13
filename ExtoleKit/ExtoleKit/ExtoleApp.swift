//
//  ExtoleApp.swift
//  firstapp
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public protocol ExtoleAppStateListener : AnyObject {
    func onStateChanged(state: ExtoleApp.State)
}

public final class ExtoleApp: SessionStateListener {
    
    public func onStateChanged(state: SessionState) {
        switch state {
        case .Verified:
            self.session!.getProfile() { profile, error in
                if let identified = profile, !(identified.email?.isEmpty ?? true) {
                    self.onProfileIdentified(identified: identified)
                }
            }
            break
        default:
            break
        }
    }
    

    public enum State : String {
        case Init = "Init"
        case LoggedOut = "LoggedOut"
        case Inactive = "Inactive"
        case InvalidToken = "InvalidToken"
        case ServerError = "ServerError"
        
        case Identify = "Identify"
        case Identified = "Identified"
        
        case ReadyToShare = "ReadyToShare"
    }
    
    private let program: Program
    
    public var session: ProgramSession? {
        get {
            return sessionManager.session
        }
    }
    
    lazy public private(set) var sessionManager: SessionManager = {
        return SessionManager.init(program: self.program, listener: self)
    }()
    
    public weak var stateListener: ExtoleAppStateListener?
    
    public init(programUrl: URL, stateListener: ExtoleAppStateListener? = nil) {
        self.program = Program.init(baseUrl: programUrl)
        self.sessionManager = SessionManager.init(program: self.program, listener: self)
    }
    
    private let label = "refer-a-friend"
    
    public let settings = UserDefaults.init()
    
    public var state = State.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: state.rawValue)
            stateListener?.onStateChanged(state: state)
        }
    }
    
    private let dispatchQueue = DispatchQueue(label : "Extole", qos:.background)
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
    
    public var profile: MyProfile?
    public var selectedShareable : MyShareable?
    //public var lastShareResult: CustomSharePollingResult?
    
    public func applicationDidBecomeActive() {
        // SFSafariViewController - to restore session
        extoleInfo(format: "applicationDidBecomeActive")
        dispatchQueue.async {
            
            if let existingToken = self.savedToken {
                self.sessionManager.activate(existingToken: existingToken)
            } else {
                self.sessionManager.newSession()
                
            }
        }
    }
    
    private func onServerError() {
        self.state = State.ServerError
    }
    
    public func identify(email: String, callback: @escaping (UpdateProfileError?) -> Void) {
        dispatchQueue.async {
            self.session!.identify(email: email) { error in
                if let _ = error {
                    callback(error)
                } else {
                    callback(nil)
                    self.session!.getProfile() { profile, error in
                        if let identified = profile, !(identified.email?.isEmpty ?? true) {
                            self.onProfileIdentified(identified: identified)
                        }
                    }
                }
            }
        }
    }

    public func updateProfile(profile: MyProfile, callback: @escaping (UpdateProfileError?) -> Void) {
        dispatchQueue.async {
            self.session!.updateProfile(profile: profile) { error in
                callback(error)
                self.session!.getProfile() { profile, error in
                    if let identified = profile {
                        self.onProfileIdentified(identified: identified)
                    }
                }
            }
        }
    }

    public func signalShare(channel: String) {
        extoleInfo(format: "shared via custom channel %s", arg: channel)
        let share = CustomShare.init(advocate_code: self.selectedShareable!.code!, channel: channel)
        self.session!.customShare(share: share) { pollingResponse, error in

            self.session!.pollCustomShare(pollingResponse: pollingResponse!) { shareResponse, error in
                self.state = State.ReadyToShare
                //self.lastShareResult = shareResponse
            }
        }
    }
    
    public func share(email: String) {
        extoleInfo(format: "sharing to email %s", arg: email)
        let share = EmailShare.init(advocate_code: self.selectedShareable!.code!,
                                     recipient_email: email)
        self.session!.emailShare(share: share) { pollingResponse, error in
            if let pollingResponse = pollingResponse {
                self.session!.pollEmailShare(pollingResponse: pollingResponse) { shareResponse, error in
                    self.state = State.ReadyToShare
                    //self.lastShareResult = shareResponse
                }
            }
        }
    }
    
    private func onProfileIdentified(identified: MyProfile) {
        self.profile = identified
        self.state = State.Identified
        self.session!.getShareables().onComplete(callback: onShareablesLoaded)
    }
    
    private func onShareablesLoaded(shareables: [MyShareable]?) {
        if let shareable = shareables?.filter({ (shareable : MyShareable) -> Bool in
            return shareable.label == self.label
        }).first {
            self.selectedShareable = shareable
            self.state = State.ReadyToShare
        } else {
            let newShareable = MyShareable.init(label: self.label,
                                                key: self.label)
            self.session!.createShareable(shareable: newShareable).onComplete { (pollingId: PollingIdResponse?) in
                self.session!.pollShareable(pollingResponse: pollingId!).onComplete(callback: { (shareableResult: ShareablePollingResult?) in
                    self.session!.getShareables().onComplete(callback: self.onShareablesLoaded)
                })
            }
        }
    }
    
    public func applicationWillResignActive() {
        extoleInfo(format: "application resign active")
        self.state = .Inactive
    }
}

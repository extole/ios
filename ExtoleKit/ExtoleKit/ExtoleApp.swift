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


public final class ExtoleApp {

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
    
    public weak var stateListener: ExtoleAppStateListener?
    
    public init(programUrl: URL, stateListener: ExtoleAppStateListener? = nil) {
        self.program = Program.init(baseUrl: programUrl)
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
    
    var accessToken: ConsumerToken?
    public var profile: MyProfile?
    public var selectedShareable : MyShareable?
    //public var lastShareResult: CustomSharePollingResult?
    
    public func applicationDidBecomeActive() {
        // SFSafariViewController - to restore session
        extoleInfo(format: "applicationDidBecomeActive")
        dispatchQueue.async {
            if let existingToken = self.savedToken {
                self.program.getToken(token: existingToken) { token, error in
                    if let verifiedToken = token {
                        self.onVerifiedToken(verifiedToken: verifiedToken)
                    }
                    if let verifyTokenError = error {
                        switch(verifyTokenError) {
                            case .invalidAccessToken : self.onTokenInvalid()
                            default: self.onServerError()
                        }
                    }
                }
            } else {
                self.program.getToken() { (token, error) in
                    if let newToken = token {
                        self.onVerifiedToken(verifiedToken: newToken)
                    }
                }
            }
        }
    }
    
    public func updateShareable(shareable: UpdateShareable, callback:
                                @escaping (UpdateShareableError?) -> Void) {
        dispatchQueue.async {
            self.program.updateShareable(accessToken: self.accessToken!,
                                         code: (self.selectedShareable?.code)!,
                                         shareable: shareable) { error in
                callback(error)
            }
        }
        
    }
    
    private func onTokenInvalid() {
        self.state = State.InvalidToken
        self.savedToken = nil
        self.program.getToken(){ token, error in
            if let newToken = token {
                self.onVerifiedToken(verifiedToken: newToken)
            }
        }
    }

    public func newSession() {
        self.state = State.Init
        self.program.getToken(){ token, error in
            if let newToken = token {
                self.onVerifiedToken(verifiedToken: newToken)
            }
        }
    }

    public func logout() {
        program.deleteToken(token: self.savedToken!) { error in
            if let _ = error {
                self.state = .ServerError
            } else {
                self.savedToken = nil
                self.state = .LoggedOut
                self.profile = nil
                self.selectedShareable = nil
                //self.lastShareResult = nil
                self.accessToken = nil
            }
            
        }
    }

    private func onServerError() {
        self.state = State.ServerError
    }

    private func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.savedToken = verifiedToken.access_token
        self.accessToken = verifiedToken
        self.state = State.Identify
        self.program.getProfile(accessToken: verifiedToken) { profile, error in
            if let identified = profile, !(identified.email?.isEmpty ?? true) {
                self.onProfileIdentified(identified: identified)
            }
        }
    }

    public func fetchObject<T: Codable>(zone: String, callback : @escaping (T?, Program.GetObjectError?) -> Void) {
        self.program.fetchObject(accessToken: self.accessToken!, zone: zone, callback: callback)
    }
    
    public func identify(email: String, callback: @escaping (UpdateProfileError?) -> Void) {
        dispatchQueue.async {
            self.program.identify(accessToken: self.accessToken!, email: email) { error in
                if let _ = error {
                    callback(error)
                } else {
                    callback(nil)
                    self.program.getProfile(accessToken: self.accessToken!) { profile, error in
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
            self.program.updateProfile(accessToken: self.accessToken!, profile: profile) { error in
                callback(error)
                self.program.getProfile(accessToken: self.accessToken!) { profile, error in
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
        self.program.customShare(accessToken: self.accessToken!, share: share) { pollingResponse, error in

            self.program.pollCustomShare(accessToken: self.accessToken!, pollingResponse: pollingResponse!) { shareResponse, error in
                self.state = State.ReadyToShare
                //self.lastShareResult = shareResponse
            }
        }
    }
    
    public func share(email: String) {
        extoleInfo(format: "sharing to email %s", arg: email)
        let share = EmailShare.init(advocate_code: self.selectedShareable!.code!,
                                     recipient_email: email)
        self.program.emailShare(accessToken: self.accessToken!, share: share) { pollingResponse, error in
            if let pollingResponse = pollingResponse {
                self.program.pollEmailShare(accessToken: self.accessToken!, pollingResponse: pollingResponse) { shareResponse, error in
                    self.state = State.ReadyToShare
                    //self.lastShareResult = shareResponse
                }
            }
        }
    }
    
    private func onProfileIdentified(identified: MyProfile) {
        self.profile = identified
        self.state = State.Identified
        self.program.getShareables(accessToken: accessToken!).onComplete(callback: onShareablesLoaded)
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
            self.program.createShareable(accessToken: accessToken!, shareable: newShareable).onComplete { (pollingId: PollingIdResponse?) in
                self.program.pollShareable(accessToken: self.accessToken!, pollingResponse: pollingId!).onComplete(callback: { (shareableResult: ShareablePollingResult?) in
                    self.program.getShareables(accessToken: self.accessToken!).onComplete(callback: self.onShareablesLoaded)
                })
            }
        }
    }
    
    public func applicationWillResignActive() {
        extoleInfo(format: "application resign active")
        self.state = .Inactive
    }
}

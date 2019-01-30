//
//  ExtoleApp.swift
//  firstapp
//
//  Created by rtibin on 1/25/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

class ExtoleApp {
    
    enum State {
        case Init
        case Inactive
        case Online
        case Identified
        case ReadyToShare
        case Busy
    }
    
    private let program = Program.init(baseUrl: "https://roman-tibin-test.extole.com")
    
    private let label = "refer-a-friend"
    
    private let settings = UserDefaults.init()
    
    let notification = NotificationCenter.init()
    
    var state = State.Init {
        didSet {
            notification.post(name: Notification.Name.state, object: self)
        }
    }
    
    private let dispatchQueue = DispatchQueue(label : "Extole", qos:.background)
    
    static let `default` = ExtoleApp()
    
    var savedToken : String? {
        get {
            return settings.string(forKey: "extole.access_token")
        }
        set(newSavedToken) {
            settings.set(newSavedToken, forKey: "extole.access_token")
        }
    }
    
    var accessToken: ConsumerToken?
    var profile: MyProfile?
    var selectedShareable : MyShareable?
    var lastShareResult: CustomSharePollingResult?
    
    func applicationDidBecomeActive() {
        Logger.Info(message: "application active")
        if let existingToken = self.savedToken {
            dispatchQueue.async {
                self.program.getToken(token: existingToken)
                    .onComplete(callback: { (token : ConsumerToken?) in
                        if let verifiedToken = token {
                            self.onVerifiedToken(verifiedToken: verifiedToken)
                        }
                    })
            }
        }
    }
    
    func onVerifiedToken(verifiedToken: ConsumerToken) {
        self.savedToken = verifiedToken.access_token
        self.accessToken = verifiedToken
        self.state = State.Online
        self.program.getProfile(accessToken: verifiedToken)
            .onComplete { (profile: MyProfile?) in
                if let identified = profile {
                    self.onProfileIdentified(identified: identified)
                }
        }
    }

    func updateProfile(profile: MyProfile) {
        dispatchQueue.async {
            self.state = State.Busy
            self.program.updateProfile(accessToken: self.accessToken!, profile: profile).onComplete { (_: SuccessResponse?) in
                self.profile = profile
                self.state = State.Identified
            }
        }
    }
    
    func share(recepient: String, message: String) {
        dispatchQueue.async {
            let share = CustomShare.init(advocate_code: self.selectedShareable!.code!, channel: "EMAIL", message: message, recipient_email: recepient, data: [:])
            self.state = State.Busy
            self.program.customShare(accessToken: self.accessToken!, share: share)
                .onComplete(callback: { (pollingResponse: PollingIdResponse?) in
                    self.program.pollCustomShare(accessToken: self.accessToken!, pollingResponse: pollingResponse!).onComplete(callback: { (shareResult: CustomSharePollingResult?) in
                        self.state = State.ReadyToShare
                        self.lastShareResult = shareResult
                    })
            })
        }
    }
    
    func onProfileIdentified(identified: MyProfile) {
        self.profile = identified
        self.state = State.Identified
        self.program.getShareables(accessToken: accessToken!).onComplete(callback: onShareablesLoaded)
    }
    
    func onShareablesLoaded(shareables: [MyShareable]?) {
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
    
    func applicationWillResignActive() {
        Logger.Info(message: "application resign active")
        self.state = .Inactive
    }
}

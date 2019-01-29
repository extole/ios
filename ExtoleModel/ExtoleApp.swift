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
        case Online
        case Identified
        case Busy
    }
    
    private let program = Program.init(baseUrl: "https://roman-tibin-test.extole.com")
    
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
        self.state = State.Busy
        self.program.updateProfile(accessToken: accessToken!, profile: profile).onComplete { (_: SuccessResponse?) in
            self.profile = profile
            self.state = State.Identified
        }
    }
    
    func onProfileIdentified(identified: MyProfile) {
        self.profile = identified
        self.state = State.Identified
    }
    
    func applicationWillResignActive() {
        Logger.Info(message: "application resign active")
    }
}

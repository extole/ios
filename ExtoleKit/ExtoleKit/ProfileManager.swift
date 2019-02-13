//
//  ProfileManager.swift
//  ExtoleKit
//
//  Created by rtibin on 2/13/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public enum ProfileState : String {
    case Init = "Init"
    case Ready = "Ready"
    case Identified = "Identified"
}

public protocol ProfileStateListener : AnyObject {
    func onStateChanged(state: ProfileState)
}

public final class ProfileManager {
    weak var listener: ProfileStateListener?
    let session: ProgramSession
    public private(set) var profile: MyProfile? = nil
    var state = ProfileState.Init {
        didSet {
            extoleInfo(format: "state changed to %{public}@", arg: state.rawValue)
            listener?.onStateChanged(state: state)
        }
    }
    
    init(session: ProgramSession, listener: ProfileStateListener?) {
        self.session = session
        self.listener = listener
    }
    
    public func load() {
        self.session.getProfile() { profile, error in
            if let identified = profile, !(identified.email?.isEmpty ?? true) {
                self.profile = identified
                self.state = .Identified
            }
        }
    }
    public func identify(email: String, callback: @escaping (UpdateProfileError?) -> Void) {
        self.session.identify(email: email) { error in
            if let _ = error {
                callback(error)
            } else {
                callback(nil)
                self.session.getProfile() { profile, error in
                    if let identified = profile, !(identified.email?.isEmpty ?? true) {
                        self.profile = identified
                        self.state = .Identified
                    }
                }
            }
        }
    }
    
    public func updateProfile(profile: MyProfile, callback: @escaping (UpdateProfileError?) -> Void) {
        self.session.updateProfile(profile: profile) { error in
            callback(error)
            self.session.getProfile() { profile, error in
                if let identified = profile {
                    self.profile = identified
                    self.state = .Identified
                }
            }
        }
    }
}

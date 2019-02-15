//Copyright © 2019 Extole. All rights reserved.

import Foundation

public protocol ProfileManagerDelegate : AnyObject {
    func loaded(profile: MyProfile)
}

public final class ProfileManager {
    weak var delegate: ProfileManagerDelegate?
    public let session: ProgramSession
    public private(set) var profile: MyProfile? = nil
    
    public init(session: ProgramSession, delegate: ProfileManagerDelegate?) {
        self.session = session
        self.delegate = delegate
    }
    
    public func load() {
        self.session.getProfile() { profile, error in
            if let identified = profile {
                self.profile = identified
                self.delegate?.loaded(profile: identified)
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
                    if let identified = profile {
                        self.profile = identified
                        self.delegate?.loaded(profile: identified)
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
                    self.delegate?.loaded(profile: identified)
                }
            }
        }
    }
}

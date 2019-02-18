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
        self.session.getProfile(success: { profile in
            if let identified = profile {
                self.profile = identified
                self.delegate?.loaded(profile: identified)
            }
        }, error: { error in
            
        })
    }
    public func identify(email: String, callback: @escaping (UpdateProfileError?) -> Void) {
        let identifyRequest = MyProfile(email: email)
        self.session.updateProfile(profile: identifyRequest, success: {
            self.load()
        }, error : { error in
            
        })
    }
    
    public func updateProfile(profile: MyProfile, callback: @escaping (UpdateProfileError?) -> Void) {
        self.session.updateProfile(profile: profile, success: {
            self.load()
        }, error : { error in
        })
    }
}

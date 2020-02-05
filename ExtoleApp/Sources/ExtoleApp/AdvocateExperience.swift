//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    public struct AdvocateExperience {
        let mobileSharing: MobileSharing
        let me: ExtoleAPI.Me.MyProfileResponse
    }
}


extension ExtoleApp.SessionManager {
    enum Zones : String {
        case mobile_sharing
    }
    public func loadZone<T: Decodable>(zone: String,
                                       success: @escaping (_ mobileSharing:  T) -> Void,
                                       error: @escaping (ExtoleAPI.Error ) -> Void) {
        self.async(command: { session in
            session.renderZone(eventName: zone, success: success, error : error)
        })
    }
    
    public func loadMobileSharing(success: @escaping (_ mobileSharing:  ExtoleApp.MobileSharing) -> Void) {
        self.loadZone(zone: Zones.mobile_sharing.rawValue, success: success, error : { e in
        })
    }

    public func loadAdvocateExperience(success: @escaping (_ advocateExperience:  ExtoleApp.AdvocateExperience) -> Void) {
        self.async { session in
            session.getProfile(success: { myProfile in
                self.loadMobileSharing(success: { mobileSharing in 
                    success(ExtoleApp.AdvocateExperience(mobileSharing: mobileSharing, me: myProfile))
                })
            }, error: { e in
                
            })
        }
    }
}

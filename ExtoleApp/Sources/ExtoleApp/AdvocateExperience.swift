//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    
    public struct AdvocateExperience {
        let mobileSharing: MobileSharing
        let me: ExtoleAPI.Me.MyProfileResponse
    }
    
    public struct AdvocateExperienceLoader: Loader {
        public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
            let loader = CompositeLoader.init(loaders: [profileLoader, mobileSharingLoader])
            loader.load(session: session, complete: complete)
        }
        let mobileSharingLoader = MobileSharingLoader()
        let profileLoader = ProfileLoader()
        
        var mobileSharing: MobileSharing? {
            get {
                return mobileSharingLoader.mobileSharing;
            }
        }
        
        var me: ExtoleAPI.Me.MyProfileResponse? {
            get {
                return profileLoader.profile;
            }
        }
    }
}

extension ExtoleApp.SessionManager {
    enum Zones : String {
        case mobile_sharing
    }
    
    public func load(loader: Loader, complete: @escaping () -> Void) {
        self.async(command: { session in
            loader.load(session: session, complete: complete)
        })
    }
    
    public func loadZone<T: Decodable>(zone: String,
                                       success: @escaping (_ zoneData:  T) -> Void,
                                       error: @escaping (ExtoleAPI.Error ) -> Void) {
        let loader = ExtoleApp.ZoneLoader<T>(zoneName: zone)
        self.load(loader: loader, complete: {
            success(loader.zoneData!)
        })
    }

    public func loadMobileSharing(success: @escaping (_ mobileSharing:  ExtoleApp.MobileSharing) -> Void) {
        self.loadZone(zone: Zones.mobile_sharing.rawValue, success: success, error : { e in
        })
    }

    public func loadAdvocateExperience(success: @escaping (_ advocateExperience:  ExtoleApp.AdvocateExperience) -> Void) {
        let loader = ExtoleApp.AdvocateExperienceLoader()
        self.load(loader: loader, complete: {
            let result = ExtoleApp.AdvocateExperience(mobileSharing: loader.mobileSharing!,
                                                      me: loader.me!)
            success(result)
        })
    }
}

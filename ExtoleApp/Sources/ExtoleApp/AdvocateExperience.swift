//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    
    public struct AdvocateExperience {
        let mobileSharing: AdvocateMobileExperience
        let me: ExtoleAPI.Me.MyProfileResponse
    }
    
    public struct AdvocateExperienceLoader: Loader {
        public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
            let loader = CompositeLoader.init(loaders: [profileLoader, mobileSharingLoader])
            loader.load(session: session, complete: complete)
        }
        let mobileSharingLoader = AdvocateMobileExperienceLoader(data: [:])
        let profileLoader = ProfileLoader()
        
        var mobileSharing: AdvocateMobileExperience? {
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

    public func loadAdvocateExperience(success: @escaping (_ advocateExperience:  ExtoleApp.AdvocateExperience) -> Void) {
        let loader = ExtoleApp.AdvocateExperienceLoader()
        self.load(loader: loader, complete: {
            let result = ExtoleApp.AdvocateExperience(mobileSharing: loader.mobileSharing!,
                                                      me: loader.me!)
            success(result)
        })
    }
}

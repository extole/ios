//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    public class MobileSharing: Decodable {
        let data: ExtoleAPI.Zones.FlatJson
        var page: ExtoleAPI.Zones.FlatJson {
           get {
               return self.data.nested(forKey: "page")
           }
        }
        var facebook: ExtoleAPI.Zones.FlatJson {
          get {
              return self.data.nested(forKey: "facebook")
          }
        }
        var twitter: ExtoleAPI.Zones.FlatJson {
          get {
              return self.data.nested(forKey: "twitter")
          }
        }
        var email: ExtoleAPI.Zones.FlatJson {
          get {
              return self.data.nested(forKey: "email")
          }
        }
        var sms: ExtoleAPI.Zones.FlatJson {
          get {
              return self.data.nested(forKey: "sms")
          }
        }
        var me: ExtoleAPI.Zones.FlatJson {
            get {
                return self.data.nested(forKey: "me")
            }
        }
        
        
    }
}

//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI



extension ExtoleApp {
    public class MobileSharing: Decodable {
        public struct Facebook {
            let json: ExtoleAPI.Zones.Json
            public var title : String? {
               get {
                   return json["title"]
               }
            }
            public var image : String? {
               get {
                   return json["image"]
               }
            }
            public var description : String? {
                get {
                  return json["description"]
                }
            }
        }
        public struct Twitter {
            let json: ExtoleAPI.Zones.Json
           
            public var message : String? {
               get {
                   return json["message"]
               }
            }
        }
        
        public struct Email {
            let json: ExtoleAPI.Zones.Json
            public var subject : String? {
              get {
                return json["subject"]
              }
            }
            public var message : String? {
               get {
                   return json["message"]
               }
            }
        }
        
        public struct Sms {
            let json: ExtoleAPI.Zones.Json
            public var message : String? {
               get {
                   return json["message"]
               }
            }
        }
        
        public struct Me {
            let json: ExtoleAPI.Zones.Json
            public var email : String? {
               get {
                   return json["email"]
               }
            }
            public var first_name : String? {
               get {
                   return json["first_name"]
               }
            }
            public var last_name : String? {
               get {
                   return json["last_name"]
               }
            }
            public var shareable_link : String? {
               get {
                   return json["shareable_link"]
               }
            }
            public var advocate_code : String? {
               get {
                   return json["advocate_code"]
               }
            }
            public var partner_user_id : String? {
               get {
                   return json["partner_user_id"]
               }
            }
            public var profile_picture_url : String? {
               get {
                   return json["profile_picture_url"]
               }
            }
        }
        
        public struct Links {
            let json: ExtoleAPI.Zones.Json
            public var company_url : String? {
              get {
                  return json["company_url"]
              }
            }
            public var terms_url : String? {
              get {
                  return json["terms_url"]
              }
            }
            public var how_it_works_url : String? {
              get {
                  return json["how_it_works_url"]
              }
            }
        }
        
        public struct CallsToAction {
            let json: ExtoleAPI.Zones.Json
            public var menu : String? {
              get {
                  return json["menu.message"]
              }
            }
            public var account_page : String? {
              get {
                  return json["account_page.message"]
              }
            }
            public var product : String? {
              get {
                  return json["product.message"]
              }
            }
            public var confirmation : String? {
              get {
                  return json["confirmation.message"]
              }
            }
        }
        
        public struct Sharing {
            let json: ExtoleAPI.Zones.Json
            public var facebook : Facebook {
              get {
                return Facebook.init(json: self.json.nested(forKey: "facebook"))
              }
            }
            public var twitter: Twitter {
              get {
                return Twitter(json: self.json.nested(forKey: "twitter"))
              }
            }
            public var email: Email {
              get {
                return Email(json: self.json.nested(forKey: "email"))
              }
            }
            public var sms: Sms {
              get {
                return Sms(json: self.json.nested(forKey: "sms"))
              }
            }
        }
        
        let data: ExtoleAPI.Zones.Json
        public var links: Links {
            get {
                return Links(json: self.data.nested(forKey: "links"))
            }
        }
        
        public var calls_to_action: CallsToAction {
            get {
                return CallsToAction(json: self.data.nested(forKey: "calls_to_action"))
            }
        }
        
        public var sharing: Sharing {
            get {
                return Sharing(json: self.data.nested(forKey: "sharing"))
            }
        }
        
        public var me: Me {
            get {
                return Me(json: self.data.nested(forKey: "me"))
            }
        }
        
        public var program_label: String? {
            get {
                return self.data["program_label"]
            }
        }
        
        public var campaign_id: String? {
            get {
                return self.data["campaign_id"]
            }
        }
    }
}

let MOBILE_SHARING_ZONE = "advocate_mobile_experience"

public final class MobileSharingLoader : Loader {
    private let data: [String:String]
    public private(set) var mobileSharing: ExtoleApp.MobileSharing? = nil
    
    init(data: [String:String]) {
        self.data = data
    }
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.renderZone(eventName: MOBILE_SHARING_ZONE,
                           data: data,
                           success: { (mobileSharing: ExtoleApp.MobileSharing) in
            self.mobileSharing = mobileSharing;
            complete()
        }, error: { error in
            complete()
        })
    }
}

extension ExtoleApp.SessionManager {

    public func loadMobileSharing(data: [String: String] = [:],
                                  success: @escaping (_ mobileSharing:  ExtoleApp.MobileSharing) -> Void) {
        let loader = MobileSharingLoader(data: data)
        self.load(loader: loader, complete: {
           success(loader.mobileSharing!)
        })
    }
}


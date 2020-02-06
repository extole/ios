//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI



extension ExtoleApp {
    public class MobileSharing: Decodable {
        public struct Page {
            let json: ExtoleAPI.Zones.Json
            public var background : String? {
                get {
                    return json["background"]
                }
            }
            public var primary_header : String? {
                get {
                    return json["primary_header"]
                }
            }
            public var reward : String? {
                get {
                    return json["reward"]
                }
            }
            public var how_it_works : String? {
                get {
                    return json["how_it_works"]
                }
            }
            public var terms_url : String? {
                get {
                    return json["terms_url"]
                }
            }
        }
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
            public var link : String? {
               get {
                   return json["link"]
               }
            }
            public var share_code : String? {
               get {
                   return json["share_code"]
               }
            }
        }
        
        let data: ExtoleAPI.Zones.Json
        public var page: Page {
           get {
            return Page(json: self.data.nested(forKey: "page"))
           }
        }
        public var facebook: Facebook {
          get {
            return Facebook(json: self.data.nested(forKey: "facebook"))
          }
        }
        public var twitter: Twitter {
          get {
            return Twitter(json: self.data.nested(forKey: "twitter"))
          }
        }
        public var email: Email {
          get {
            return Email(json: self.data.nested(forKey: "email"))
          }
        }
        public var sms: Sms {
          get {
            return Sms(json: self.data.nested(forKey: "sms"))
          }
        }
        public var me: Me {
            get {
                return Me(json: self.data.nested(forKey: "me"))
            }
        }
        
        public var label: String? {
            get {
                return self.data["label"]
            }
        }
        
        public var target_url: String? {
            get {
                return self.data["target_url"]
            }
        }
        
        public var bundle_name: String? {
            get {
                return self.data["bundle_name"]
            }
        }
    }
}

let MOBILE_SHARING_ZONE = "mobile_sharing"

public final class MobileSharingLoader : Loader {
    public private(set) var mobileSharing: ExtoleApp.MobileSharing? = nil
    
    public func load(session: ExtoleAPI.Session, complete: @escaping () -> Void) {
        session.renderZone(eventName: MOBILE_SHARING_ZONE,
                           success: { (mobileSharing: ExtoleApp.MobileSharing) in
            self.mobileSharing = mobileSharing;
            complete()
        }, error: { error in
            complete()
        })
    }
}

extension ExtoleApp.SessionManager {

    public func loadMobileSharing(success: @escaping (_ mobileSharing:  ExtoleApp.MobileSharing) -> Void) {
        let loader = MobileSharingLoader()
        self.load(loader: loader, complete: {
           success(loader.mobileSharing!)
        })
    }
}


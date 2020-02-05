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
    }
}

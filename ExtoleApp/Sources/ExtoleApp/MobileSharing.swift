//Copyright © 2019 Extole. All rights reserved.

import Foundation
import ExtoleAPI

extension ExtoleApp {
    public class MobileSharing: Decodable {
        public struct Page {
            let json: ExtoleAPI.Zones.FlatJson
            var background : String? {
                get {
                    return json["background"]
                }
            }
            var primary_header : String? {
                get {
                    return json["primary_header"]
                }
            }
            var reward : String? {
                get {
                    return json["reward"]
                }
            }
            var how_it_works : String? {
                get {
                    return json["how_it_works"]
                }
            }
            var terms_url : String? {
                get {
                    return json["terms_url"]
                }
            }
        }
        public struct Facebook {
            let json: ExtoleAPI.Zones.FlatJson
            var title : String? {
               get {
                   return json["title"]
               }
            }
            var image : String? {
               get {
                   return json["image"]
               }
            }
            var description : String? {
                get {
                  return json["description"]
                }
            }
        }
        public struct Twitter {
            let json: ExtoleAPI.Zones.FlatJson
           
            var message : String? {
               get {
                   return json["message"]
               }
            }
        }
        
        public struct Email {
            let json: ExtoleAPI.Zones.FlatJson
            var subject : String? {
              get {
                return json["subject"]
              }
            }
            var message : String? {
               get {
                   return json["message"]
               }
            }
        }
        
        public struct Sms {
            let json: ExtoleAPI.Zones.FlatJson
            var message : String? {
               get {
                   return json["message"]
               }
            }
        }
        
        public struct Me {
            let json: ExtoleAPI.Zones.FlatJson
            var email : String? {
               get {
                   return json["email"]
               }
            }
            var first_name : String? {
               get {
                   return json["first_name"]
               }
            }
            var last_name : String? {
               get {
                   return json["last_name"]
               }
            }
            var link : String? {
               get {
                   return json["link"]
               }
            }
            var share_code : String? {
               get {
                   return json["share_code"]
               }
            }
        }
        
        let data: ExtoleAPI.Zones.FlatJson
        var page: Page {
           get {
            return Page(json: self.data.nested(forKey: "page"))
           }
        }
        var facebook: Facebook {
          get {
            return Facebook(json: self.data.nested(forKey: "facebook"))
          }
        }
        var twitter: Twitter {
          get {
            return Twitter(json: self.data.nested(forKey: "twitter"))
          }
        }
        var email: Email {
          get {
            return Email(json: self.data.nested(forKey: "email"))
          }
        }
        var sms: Sms {
          get {
            return Sms(json: self.data.nested(forKey: "sms"))
          }
        }
        var me: Me {
            get {
                return Me(json: self.data.nested(forKey: "me"))
            }
        }
        
        
    }
}

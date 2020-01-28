//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI.Zones {
    struct AnyKey: CodingKey {
        init?(intValue: Int) {
            self.stringValue = "??"
        }
        
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? = nil
    }
    public struct ZoneResponse : Decodable {
        public struct Data: Decodable {
            subscript (name:String) -> String? {
                return name
            }
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: AnyKey.self)
                try container.allKeys.forEach { key in
                    let value = try container.decode(String.self, forKey:  key)
                    print(key.stringValue + " : " + value)
                }
            }
        }
        
        let event_id: String
        let data: Data
    }
}

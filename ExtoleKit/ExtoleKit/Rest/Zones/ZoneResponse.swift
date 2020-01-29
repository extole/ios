//Copyright © 2019 Extole. All rights reserved.

import Foundation

struct AnyKey: CodingKey {
   var stringValue: String
   var intValue: Int? = nil
   init?(intValue: Int) {
       self.stringValue = "??"
   }
   init?(stringValue: String) {
       self.stringValue = stringValue
   }
}

func decodeSingle(container: SingleValueDecodingContainer) -> String? {
    do {
        let value = try container.decode(Int64.self)
        return String(value)
    } catch {
    }
    
    do {
        let value = try container.decode(Double.self)
        return String(value)
    } catch {
    }
    
    do {
        let value = try container.decode(Bool.self)
        return String(value)
    } catch {
    }
    
    do {
        let value = try container.decode(String.self)
        return value
    } catch {
    }
    return nil
}

extension ExtoleAPI.Zones {
    
    public struct FlatJson: Decodable {
        var value : String? = nil
        var nested: [String: FlatJson] = [:]
        subscript (name:String) -> String? {
            if (name.isEmpty) {
                return value
            }
            let parts = name.split(separator: ".")
            let firstPart = String(parts[0])
            let data = nested[firstPart]
            if let existingData = data {
                let subName = name.dropFirst(firstPart.count + 1)
                return existingData[String(subName)]
            }
            return nil
        }
        init(value: String) {
           self.value = value
        }
       
        public init(from decoder: Decoder) throws {
            // handle single value
            do {
                let singleValueContainer = try decoder.singleValueContainer()
                if let stringValue = decodeSingle(container: singleValueContainer) {
                    self.value = stringValue
                    return
                }
            } catch {
            }
            // handle array
            do {
                var arrayContainer = try decoder.unkeyedContainer()
                var arrayData: [FlatJson] = []
                
                let indexes = (0...(arrayContainer.count ?? 0))
                indexes.forEach { index in
                    do {
                        let dataAttribute = try arrayContainer.decode(FlatJson.self)
                        arrayData.append(dataAttribute)
                    } catch {
                        print(" is not a data at " + String(index))
                    }
                }
                self.nested = [:]
                self.value = String(arrayData.count)
                for (index, data) in arrayData.enumerated() {
                    self.nested[String(index)] = data
                }
                return
            } catch {
                print("not array")
            }
            // handle object
            let container = try decoder.container(keyedBy: AnyKey.self)
            var dataAttributes : [String: FlatJson] = [:]
            container.allKeys.forEach { key in
                do {
                    let dataAttribute = try container.decode(FlatJson.self, forKey: key)
                    dataAttributes[key.stringValue] = dataAttribute
                } catch {
                    print(key.stringValue + " is not a data")
                }
            }
            self.nested = dataAttributes
        }
    }
   
    public struct ZoneResponse : Decodable {
        let event_id: String
        let data: FlatJson
    }
}

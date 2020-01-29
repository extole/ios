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
   
    public struct ZoneResponse : Decodable {
        public struct Data: Decodable {
            var value : String? = nil
            var datas: [String: Data] = [:]
            subscript (name:String) -> String? {
                if (name.isEmpty) {
                    return value
                }
                let parts = name.split(separator: ".")
                let firstPart = String(parts[0])
                let data = datas[firstPart]
                if let existingData = data {
                    let subName = name.dropFirst(firstPart.count + 1)
                    return existingData[String(subName)]
                }
                return nil
            }
            init(value: String) {
               self.value = value
            }
            init(array: [Data]) {
                self.datas = [:]
                self.value = String(array.count)
                for (index, data) in array.enumerated() {
                    self.datas[String(index)] = data
                }
            }
            public init(from decoder: Decoder) throws {
                do {
                    let singleValueContainer = try decoder.singleValueContainer()
                    if let stringValue = decodeSingle(container: singleValueContainer) {
                        self.value = stringValue
                        return
                    }
                } catch {
                    
                }
                let container = try decoder.container(keyedBy: AnyKey.self)
                var dataAttributes : [String: Data] = [:]
                container.allKeys.forEach { key in
                    do {
                        var arrayContainer = try container.nestedUnkeyedContainer(forKey: key)
                        var arrayData: [Data] = []
                        
                        let indexes = (0...(arrayContainer.count ?? 0))
                        indexes.forEach { index in
                            do {
                                let dataAttribute = try arrayContainer.decode(Data.self)
                                arrayData.append(dataAttribute)
                            } catch {
                                print(key.stringValue + " is not a data")
                            }
                        }
                        dataAttributes[key.stringValue] = Data.init(array: arrayData)
                        //stringAttributes[key.stringValue] = String(arrayContainer.count ?? -1)
                    } catch {
                        print("not array")
                    }
                    do {
                        let dataAttribute = try container.decode(Data.self, forKey: key)
                        dataAttributes[key.stringValue] = dataAttribute
                    } catch {
                        print(key.stringValue + " is not a data")
                    }
                }
                self.datas = dataAttributes
            }
        }
        
        let event_id: String
        let data: Data
    }
}

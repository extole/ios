//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Zones {
        static func v6ZonesUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v6/zones/", relativeTo: baseUrl)!
        }
    }
}

extension ExtoleAPI.Session {
    func renderZone<T: Codable>(eventName: String, data: [String:String]?,
                    success: @escaping(_: T) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let zoneUrl = ExtoleAPI.Zones.v6ZonesUrl(baseUrl: self.baseUrl)
        let renderZoneRequest = ExtoleAPI.Zones.RenderZoneRequest(event_name: eventName, data: data ?? [:])
        let urlRequest = self.postRequest(url: zoneUrl, data: renderZoneRequest)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
}

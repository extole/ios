//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Events {
        static func eventsUrl(baseUrl: URL) -> URL {
           return URL.init(string: "/api/v6/events/", relativeTo: baseUrl)!
        }
    }
}

extension ExtoleAPI.Session {
    public func submitEvent(eventName: String,
                    data: [String:String] = [:],
                    success: @escaping(_: ExtoleAPI.Events.SubmitEventResponse) -> Void,
                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let eventUrl = ExtoleAPI.Events.eventsUrl(baseUrl: self.baseUrl)
        let headers = [
            "Accept": "application/json",
            "Authorization": "Bearer " + self.accessToken
        ]
        let renderZoneRequest = ExtoleAPI.Events.SubmitEventRequest(event_name: eventName, data: data)
        let urlRequest = self.postRequest(url: eventUrl, data: renderZoneRequest,
                                          headers: headers)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
}

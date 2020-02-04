//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Person {
    }
}

func personsUrl(baseUrl: URL) -> URL {
   return URL.init(string: "/api/v4/persons/", relativeTo: baseUrl)!
}

extension ExtoleAPI.Session {
    public func getPublicPerson(personId: String,
                                success: @escaping(_: ExtoleAPI.Person.PublicPersonResponse) -> Void,
                                error: @escaping (_: ExtoleAPI.Error) -> Void) {
        let publicPersonUrl = URL.init(string: personId, relativeTo: personsUrl(baseUrl: self.baseUrl))!
        let urlRequest = self.getRequest(url: publicPersonUrl)

        self.network.processRequest(with: urlRequest, success: success, error: error)
    }
}

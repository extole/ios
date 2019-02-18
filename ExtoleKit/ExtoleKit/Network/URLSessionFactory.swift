//Copyright © 2019 Extole. All rights reserved.

import Foundation

public class URLSessionFactory {
    public func createSession() -> URLSession {
       return URLSession.init(configuration: URLSessionConfiguration.ephemeral)
    }
}

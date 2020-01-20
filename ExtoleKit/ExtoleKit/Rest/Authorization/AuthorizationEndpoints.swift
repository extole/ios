//Copyright © 2019 Extole. All rights reserved.

import Foundation

extension ExtoleAPI {
    public enum Authorization {
        public static func v5TokenUrl(baseUrl: URL) -> URL {
          return URL.init(string: "/api/v5/token/", relativeTo: baseUrl)!
        }
        public static func v4TokenUrl(baseUrl: URL) -> URL {
          return URL.init(string: "/api/v4/token/", relativeTo: baseUrl)!
        }
   }
}

extension ExtoleAPI.Error {
    func isInvalidAccessToken() -> Bool {
        return code == "invalid_access_token"
    }
    func isMissingAccessToken() -> Bool {
        return code == "missing_access_token"
    }
    func isExpiredAccessToken() -> Bool {
        return code == "expired_access_token"
    }
    func isInvalidProgramDomain() -> Bool {
        return code == "invalid_program_domain"
    }
}


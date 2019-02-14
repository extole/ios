//Copyright © 2019 Extole. All rights reserved.

import Foundation

public struct ErrorData: Codable {
    let code: String
}

public enum ExtoleApiError {
    case serverError(error: Error)
    case decodingError(data: Data)
    case noContent
    case genericError(errorData: ErrorData)
}

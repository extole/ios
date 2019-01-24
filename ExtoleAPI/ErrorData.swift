//
//  ErrorData.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

public struct ErrorData: Codable {
    let code: String
}

enum ExtoleServerError : Error {
    case serverError(errorData: ErrorData)
    case encodingError
    case noContent
}

enum ExtoleClientError : Error {
    case pollingTimeout
}

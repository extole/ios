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

public enum ExtoleApiError {
    case serverError(error: Error)
    case decodingError(data: Data)
    case noContent
    case genericError(errorData: ErrorData)
}

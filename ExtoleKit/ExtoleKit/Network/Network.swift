//
//  Network.swift
//  firstapp
//
//  Created by rtibin on 1/24/19.
//  Copyright © 2019 rtibin. All rights reserved.
//

import Foundation

func version(for bundle: Bundle) -> String {
    return bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "unknown"
}

class ExtoleHeaders {
    static let all = [
        "X-Extole-App": "Mobile SDK",
        "X-Extole-App-flavour": "iOS-Swift",
        "X-Extole-Sdk-version": version(for: Bundle(for: ExtoleHeaders.self)),
    
        "X-Extole-App-version": version(for: Bundle.main),
        "X-Extole-App-appId": Bundle.main.bundleIdentifier ?? "unknown",
        "X-Extole-DeviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown",
    ]
}


func tryDecode<T: Codable>(data: Data) -> T? {
    let decoder = JSONDecoder.init()
    return try? decoder.decode(T.self, from: data)
}

func getRequest(accessToken: ConsumerToken? = nil, url: URL) -> URLRequest {
    let empty : String? = nil
    return jsonRequest(method: "GET", accessToken: accessToken, url: url, data: empty)
}

func postRequest<T : Encodable>(accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
    return jsonRequest(method: "POST", accessToken: accessToken, url: url, data: data)
}

func putRequest<T : Encodable>(accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
    return jsonRequest(method: "PUT", accessToken: accessToken, url: url, data: data)
}

func deleteRequest(accessToken: ConsumerToken? = nil, url: URL) -> URLRequest {
    let empty : String? = nil
    return jsonRequest(method: "DELETE", accessToken: accessToken, url: url, data: empty)
}

func jsonRequest<T : Encodable>(method: String, accessToken: ConsumerToken? = nil, url: URL, data: T? = nil) -> URLRequest {
    var request = URLRequest(url: url)
    extoleDebug(format: "url %{public}@", arg: url.absoluteString)
    extoleDebug(format: "method %{public}@", arg: method)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    ExtoleHeaders.all.forEach { (key, value) in
        request.addValue(value, forHTTPHeaderField: key)
    }
    
    if let data = data, let encoded = try? JSONEncoder().encode(data) {
        request.httpBody = encoded
        extoleDebug(format: "body %{public}@", arg: (String(data: encoded, encoding: .utf8)))
    }
    if let existingToken = accessToken {
        extoleDebug(format: "using accessToken %{private}@", arg: existingToken.access_token)
        request.addValue(existingToken.access_token, forHTTPHeaderField: "Authorization")
    }
    return request
}

func processRequest(with request: URLRequest,
                    callback:  @escaping (_: Data?, _: ExtoleApiError?) -> Void) {
    let session = URLSession.init(configuration: URLSessionConfiguration.ephemeral)
    let task = session.dataTask(with: request) { data, response, error in
        if let serverError = error {
            callback(nil, ExtoleApiError.serverError(error: serverError))
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                if let responseData = data {
                    let decodedError: ErrorData? = tryDecode(data: responseData)
                    if let decodedError = decodedError {
                        callback(nil, .genericError(errorData: decodedError))
                    } else {
                        callback(nil, .decodingError(data: responseData))
                    }
                } else {
                    callback(nil, .noContent)
                }
                return
        }
        if let responseData = data {
            let responseDataString = String(data: responseData, encoding: .utf8)!
            extoleDebug(format: "processRequest : %{public}@", arg: responseDataString)
            callback(responseData, nil)
        } else {
            callback(nil, .noContent)
        }
    }
    task.resume()
}

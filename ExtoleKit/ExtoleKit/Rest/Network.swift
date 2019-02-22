//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public class NetworkExecutor : NSObject {
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = urlSession.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
}

@objc public class Network : NSObject {
    
    let executor : NetworkExecutor
    
    @objc public init(executor: NetworkExecutor = NetworkExecutor.init()) {
        self.executor = executor
    }
    
    func tryDecode<T: Codable>(data: Data) -> T? {
        let decoder = JSONDecoder.init()
        return try? decoder.decode(T.self, from: data)
    }

    func getRequest(accessToken: ConsumerToken? = nil, url: URL) -> URLRequest {
        let empty : String? = nil
        return newJsonRequest(method: "GET", accessToken: accessToken, url: url, data: empty)
    }

    func postRequest<T : Encodable>(accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
        return newJsonRequest(method: "POST", accessToken: accessToken, url: url, data: data)
    }

    func putRequest<T : Encodable>(accessToken: ConsumerToken? = nil, url: URL, data: T) -> URLRequest {
        return newJsonRequest(method: "PUT", accessToken: accessToken, url: url, data: data)
    }

    func deleteRequest(accessToken: ConsumerToken? = nil, url: URL) -> URLRequest {
        let empty : String? = nil
        return newJsonRequest(method: "DELETE", accessToken: accessToken, url: url, data: empty)
    }

    private func newJsonRequest<T : Encodable>(method: String, accessToken: ConsumerToken? = nil, url: URL, data: T? = nil) -> URLRequest {
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

    final func dataHandler<T : Codable, E: ExtoleError>(success: @escaping (_: T?) -> Void,
                                                  error: @escaping(_: E) -> Void)
        -> ((_ : Data?) -> Void)  {
            return { data in
                if let data = data {
                    let decodedToken : T? = self.tryDecode(data: data)
                    if let token = decodedToken {
                        success(token)
                    } else {
                        let errorValue:E = E.toInvalidProtocol(error: .decodingError(data: data)) as! E
                        error(errorValue)
                    }
                }
            }
    }

    final func errorHandler<E: ExtoleError>(error: @escaping(_: E) -> Void)
        -> ((_ : ExtoleApiError) -> Void)  {
            return { apiError in
                switch(apiError) {
                case .genericError(let errorData) : do {
                    if let fromCode = E.fromCode(code: errorData.code) {
                        error(fromCode as! E)
                    } else {
                        let errorValue:E = E.toInvalidProtocol(error: apiError) as! E
                        error(errorValue)
                    }
                    }
                default : do {
                    let errorValue:E = E.toInvalidProtocol(error: apiError) as! E
                    error(errorValue)
                    }
                }
            }
    }

    func processRequest(with request: URLRequest,
                        dataHandler:  @escaping (_: Data?) -> Void,
                        errorHandler: @escaping(_: ExtoleApiError) -> Void) {
        executor.dataTask(with: request) { data, response, error in
            if let serverError = error {
                errorHandler(ExtoleApiError.serverError(error: serverError))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let responseData = data {
                        let decodedError: ErrorData? = self.tryDecode(data: responseData)
                        if let decodedError = decodedError {
                            errorHandler(.genericError(errorData: decodedError))
                        } else {
                            errorHandler(.decodingError(data: responseData))
                        }
                    } else {
                        errorHandler(.noContent)
                    }
                    return
            }
            if let responseData = data {
                let responseDataString = String(data: responseData, encoding: .utf8)!
                extoleDebug(format: "processRequest : %{public}@", arg: responseDataString)
                dataHandler(responseData)
            } else {
                errorHandler(.noContent)
            }
        }
    }

    func processRequest<T: Codable, E: ExtoleError>(with request: URLRequest,
                                                    success : @escaping (_: T?) -> Void,
                                                    error: @escaping (_: E) -> Void) {
        processRequest(with: request,
                       dataHandler :dataHandler(success: success, error: error),
                       errorHandler:errorHandler(error: error))
    }

    func processNoContentRequest<E: ExtoleError>(with request: URLRequest,
                                             success : @escaping () -> Void,
                                             error: @escaping (_: E) -> Void) {
        processRequest(with: request,
                       dataHandler :{ _ in success()},
                       errorHandler:errorHandler(error: error))
    }
      
}



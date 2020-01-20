//Copyright © 2019 Extole. All rights reserved.

import Foundation

@objc public protocol NetworkExecutor {
    @objc func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void);
}

@objc public class DefaultNetworkExecutor : NSObject, NetworkExecutor {
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    public func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = urlSession.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
}

public protocol ExtoleApiErrorHandler {
    func serverError(error: Error)
    func decodingError(data: Data)
    func noContent()
    func genericError(errorData: ExtoleAPI.Error)
}

public class Network : NSObject {
    
    let executor : NetworkExecutor
    
    public init(executor: NetworkExecutor = DefaultNetworkExecutor.init()) {
        self.executor = executor
    }
    
    func tryDecode<T: Codable>(data: Data) -> T? {
        let decoder = JSONDecoder.init()
        return try? decoder.decode(T.self, from: data)
    }

    func newJsonRequest<T : Encodable>(method: String, url: URL, headers: [String: String],  data: T? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        extoleDebug(format: "url %{public}@", arg: url.absoluteString)
        extoleDebug(format: "method %{public}@", arg: method)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        ExtoleHeaders.all.forEach { (key, value) in
            extoleDebug(format: "adding header %{private}@", arg: key)
            request.addValue(value, forHTTPHeaderField: key)
        }
    
        if let data = data, let encoded = try? JSONEncoder().encode(data) {
            request.httpBody = encoded
            extoleDebug(format: "body %{public}@", arg: (String(data: encoded, encoding: .utf8)))
        }
        headers.forEach { (key, value) in
            extoleDebug(format: "adding header %{private}@", arg: key)
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }

    final func dataHandler<T : Codable>(success: @escaping (_: T) -> Void,
                                        error: @escaping(ExtoleAPI.Error) -> Void)
        -> ((_ : Data?) -> Void)  {
            return { data in
                if let data = data {
                    let decoded : T? = self.tryDecode(data: data)
                    if let token = decoded {
                        success(token)
                    } else {
                        let errorValue = ExtoleAPI.Error(code: "ExtoleKit-decoding")
                        error(errorValue)
                    }
                }
            }
    }

    class DefaultExtoleApiErrorHandler : ExtoleApiErrorHandler {
        private let error:((_: ExtoleAPI.Error) -> Void)
        init(error: @escaping(_: ExtoleAPI.Error) -> Void) {
            self.error = error
        }
        func serverError(error: Error) {
            self.error(ExtoleAPI.Error.init(code: "ExtoleKit-server"))
        }
        
        func decodingError(data: Data) {
             self.error(ExtoleAPI.Error.init(code: "ExtoleKit-decoding"))
        }
        
        func noContent() {
             self.error(ExtoleAPI.Error.init(code: "ExtoleKit-nocontent"))
        }
        
        func genericError(errorData: ExtoleAPI.Error) {
            error(errorData)
        }
        
        
    }
    final func errorHandler(error: @escaping(_: ExtoleAPI.Error) -> Void)
        -> ExtoleApiErrorHandler  {
            return DefaultExtoleApiErrorHandler(error: error)
    }

    func processRequest(with request: URLRequest,
                        dataHandler:  @escaping (_: Data) -> Void,
                        errorHandler: ExtoleApiErrorHandler) {
        executor.dataTask(with: request) { data, response, error in
            if let serverError = error {
                errorHandler.serverError(error: serverError)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    if let responseData = data {
                        let serverError: ExtoleAPI.ServerError? = self.tryDecode(data: responseData)
                        if let serverError = serverError {
                            let error = ExtoleAPI.Error(code: serverError.code, message: serverError.message, httpCode: serverError.http_status_code)
                            errorHandler.genericError(errorData: error)
                        } else {
                            errorHandler.decodingError(data: responseData)
                        }
                    } else {
                        errorHandler.noContent()
                    }
                    return
            }
            if let responseData = data {
                let responseDataString = String(data: responseData, encoding: .utf8)!
                extoleDebug(format: "processRequest : %{public}@", arg: responseDataString)
                dataHandler(responseData)
            } else {
                errorHandler.noContent()
            }
        }
    }

    func processRequest<T: Codable>(with request: URLRequest,
                                    success : @escaping (_: T) -> Void,
                                    error: @escaping (_: ExtoleAPI.Error) -> Void) {
        processRequest(with: request,
                       dataHandler :dataHandler(success: success, error: error),
                       errorHandler:errorHandler(error: error))
    }

    func processNoContentRequest(with request: URLRequest,
                                             success : @escaping () -> Void,
                                             error: @escaping (_: ExtoleAPI.Error) -> Void) {
        processRequest(with: request,
                       dataHandler :{ _ in success()},
                       errorHandler:errorHandler(error: error))
    }
      
}

import Foundation

protocol HTTPRequestInterceptorProtocol {
    /// Implements an interception
    /// - Parameters:
    ///   - request: a mutable object of type `(URLRequest)`
    ///   - authorized: an object of type `(Bool)` that represents if the endpoint requires token
    func intercept(_ request: inout URLRequest, authorized: Bool)
}

/// Implements an Interceptor to intercept network calls to add a token
final class HTTPRequestInterceptor: HTTPRequestInterceptorProtocol {
    private let sessionDataSource: SessionDataSourceProtocol
    
    init(sessionDataSource: SessionDataSourceProtocol = SessionDataSource.shared) {
        self.sessionDataSource = sessionDataSource
    }
    
    func intercept(_ request: inout URLRequest, authorized: Bool) {
        guard let jwt = sessionDataSource.get(), authorized else {
            return
        }
        
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
    }
}

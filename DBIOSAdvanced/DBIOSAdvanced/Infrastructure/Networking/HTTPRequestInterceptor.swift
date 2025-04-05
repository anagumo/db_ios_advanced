import Foundation
import OSLog

protocol HTTPRequestInterceptorProtocol {
    /// Implements an interception
    /// - Parameters:
    ///   - request: a mutable object of type `(URLRequest)`
    ///   - authorized: an object of type `(Bool)` that represents if the endpoint requires token
    func intercept(_ request: inout URLRequest, authorized: Bool)
}

/// Implements an Interceptor to intercept network calls to add a token
final class HTTPRequestInterceptor: HTTPRequestInterceptorProtocol {
    private let sessionLocalDataSource: SessionLocalDataSourceProtocol
    
    init(sessionLocalDataSource: SessionLocalDataSourceProtocol = SessionLocalDataSource.shared) {
        self.sessionLocalDataSource = sessionLocalDataSource
    }
    
    func intercept(_ request: inout URLRequest, authorized: Bool) {
        guard let jwt = sessionLocalDataSource.get(), authorized else {
            if authorized {
                Logger.log("JWT expired", level: .notice, layer: .infraestructure)
            } else {
                Logger.log("The endpoint does not require Authorization", level: .info, layer: .infraestructure)
            }
            return
        }
        
        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
    }
}

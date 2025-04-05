import Foundation
import OSLog

struct HTTPRequestBuilder {
    let requestComponents: any HTTPRequestComponents
    
    init(requestComponents: any HTTPRequestComponents) {
        self.requestComponents = requestComponents
    }
    
    private func url() throws -> URL {
        var urlComponents: URLComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = requestComponents.host
        urlComponents.path = requestComponents.path
        
        if let queryParameters = requestComponents.queryParameters {
            Logger.log("The URL has query params: \(queryParameters)", level: .debug, layer: .infraestructure)
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = urlComponents.url else {
            Logger.log("Failed to create an URL", level: .error, layer: .infraestructure)
            throw APIError.malformedURL(url: requestComponents.path)
        }
        
        return url
    }
    
    func build() throws -> URLRequest {
        do {
            var urlRequest = try URLRequest(url: url())
            urlRequest.httpMethod = requestComponents.method.rawValue
            
            if let httpBody = requestComponents.body {
                Logger.log("The URL request has body: \(httpBody)", level: .debug, layer: .infraestructure)
                urlRequest.httpBody = try JSONEncoder().encode(httpBody)
            }
            
            urlRequest.allHTTPHeaderFields = [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json"
            ].merging(requestComponents.headers) { $1 }
            
            return urlRequest
        } catch {
            Logger.log("Failed to create an URL request", level: .error, layer: .infraestructure)
            throw APIError.badRequest(url: requestComponents.path)
        }
    }
}

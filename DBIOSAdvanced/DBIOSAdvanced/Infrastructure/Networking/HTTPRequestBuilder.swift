import Foundation

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
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw APIError.malformedURL(url: requestComponents.path)
        }
        
        return url
    }
    
    func build() throws -> URLRequest {
        do {
            var urlRequest = try URLRequest(url: url())
            urlRequest.httpMethod = requestComponents.method.rawValue
            
            if let httpBody = requestComponents.body {
                urlRequest.httpBody = try JSONEncoder().encode(httpBody)
            }
            
            urlRequest.allHTTPHeaderFields = [
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json"
            ].merging(requestComponents.headers) { $1 }
            
            return urlRequest
        } catch {
            throw APIError.badRequest(url: requestComponents.path)
        }
    }
}

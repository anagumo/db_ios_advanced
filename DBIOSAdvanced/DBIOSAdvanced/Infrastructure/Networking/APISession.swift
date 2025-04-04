import Foundation
import OSLog

protocol APISessionProtocol {
    /// A generic function that implements a request using  an URL Session
    /// - Parameters:
    ///   - requestComponents: an object of type `(HTTPRequestComponents)` that represents a request to the server and contains an URL, headers, etc.
    ///   - completion: a clossure of type `(ResponseCompletion)`  that represents the data result and returns either a Decodable  or an Error
    func request<RequestComponents: HTTPRequestComponents>(
        _ requestComponents: RequestComponents,
        completion: @escaping RequestComponents.ResponseCompletion
    )
}

final class APISession: APISessionProtocol {
    static let shared = APISession()
    private let urlSession: URLSession
    private let httpRequestInterceptors: [HTTPRequestInterceptor]
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.httpRequestInterceptors = [HTTPRequestInterceptor()]
    }
    
    func request<RequestComponents: HTTPRequestComponents>(
        _ requestComponents: RequestComponents,
        completion: @escaping RequestComponents.ResponseCompletion
    ) {
        let path = requestComponents.path
        do {
            var urlRequest = try HTTPRequestBuilder(requestComponents: requestComponents).build()
            
            // Applies all interceptors
            httpRequestInterceptors.forEach { httpRequestInterceptor in
                httpRequestInterceptor.intercept(
                    &urlRequest,
                    authorized: requestComponents.authorized
                )
            }
            
            urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
                guard error == nil else {
                    guard let error = error as? NSError else {
                        completion(.failure(APIError.unknown(url: path)))
                        return
                    }
                    completion(.failure(APIError.server(url: path, statusCode: error.code)))
                    return
                }
                
                let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode
                guard let statusCode else {
                    completion(.failure(APIError.server(url: path, statusCode: statusCode)))
                    return
                }
                
                guard let data else {
                    completion(.failure(APIError.noData(url: path, statusCode: statusCode)))
                    return
                }
                
                switch statusCode {
                case 200..<300:
                    // Validation for Login response data since is not a JSON
                    if RequestComponents.Response.self == Data.self {
                        completion(.success(data as! RequestComponents.Response))
                    } else {
                        do {
                            let decodedData = try JSONDecoder().decode(RequestComponents.Response.self, from: data)
                            completion(.success(decodedData))
                        } catch {
                            completion(.failure(APIError.decoding(url: path)))
                        }
                    }
                case 401:
                    // Represents an unauthorized error to provide feedback about wrong email or password
                    completion(.failure(APIError.unauthorized(url: path, statusCode: statusCode)))
                default:
                    completion(.failure(APIError.server(url: path, statusCode: statusCode)))
                }
            }.resume()
        } catch {
            completion(.failure(APIError.badRequest(url: path)))
        }
    }
}

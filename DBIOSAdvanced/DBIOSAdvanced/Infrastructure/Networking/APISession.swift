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
    private let httpRequestInterceptors: [HTTPRequestInterceptorProtocol]
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        self.httpRequestInterceptors = [HTTPRequestInterceptor()]
    }
    
    func request<RequestComponents: HTTPRequestComponents>(
        _ requestComponents: RequestComponents,
        completion: @escaping RequestComponents.ResponseCompletion
    ) {
        do {
            var urlRequest = try HTTPRequestBuilder(requestComponents: requestComponents).build()
            // Applies all interceptors
            httpRequestInterceptors.forEach { httpRequestInterceptor in
                httpRequestInterceptor.intercept(&urlRequest, authorized: requestComponents.authorized)
            }
            // Make a network call
            urlSession.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
                guard error == nil else {
                    guard let error = error as? NSError else {
                        Logger.log("Failed to cast to NSError", level: .error, layer: .infraestructure)
                        completion(.failure(APIError.unknown(url: requestComponents.path)))
                        return
                    }
                    Logger.log("Failed netwkork call with code: \(error.code)", level: .error, layer: .infraestructure)
                    completion(.failure(APIError.server(url: requestComponents.path, statusCode: error.code)))
                    return
                }
                
                let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode
                self?.manageResponse(
                    requestComponents: requestComponents,
                    statusCode: statusCode,
                    data: data,
                    completion: completion
                )
            }.resume()
        } catch {
            Logger.log("Failed to build an URLRequest", level: .error, layer: .infraestructure)
            completion(.failure(APIError.badRequest(url: requestComponents.path)))
        }
    }
    
    private func manageResponse<RequestComponents: HTTPRequestComponents>(
        requestComponents: RequestComponents,
        statusCode: Int?,
        data: Data?,
        completion: @escaping RequestComponents.ResponseCompletion
    ) {
        guard let statusCode else {
            Logger.log("Unexpected nil in status code", level: .error, layer: .infraestructure)
            completion(.failure(APIError.server(url: requestComponents.path, statusCode: statusCode)))
            return
        }
        
        guard let data else {
            Logger.log("Unexpected nil in data", level: .error, layer: .infraestructure)
            completion(.failure(APIError.noData(url: requestComponents.path, statusCode: statusCode)))
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
                    Logger.log("Failed to decoding from data", level: .error, layer: .infraestructure)
                    completion(.failure(APIError.decoding(url: requestComponents.path)))
                }
            }
        case 401:
            // Represents an unauthorized error to provide feedback about wrong email or password
            Logger.log("Authorization failed", level: .error, layer: .infraestructure)
            completion(.failure(APIError.unauthorized(url: requestComponents.path, statusCode: statusCode)))
        default:
            Logger.log("Failed handle response with code: \(statusCode)", level: .error, layer: .infraestructure)
            completion(.failure(APIError.server(url: requestComponents.path, statusCode: statusCode)))
        }
    }
}

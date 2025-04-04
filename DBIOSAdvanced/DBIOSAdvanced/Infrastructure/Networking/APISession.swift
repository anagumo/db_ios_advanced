import Foundation

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
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request<RequestComponents: HTTPRequestComponents>(
        _ requestComponents: RequestComponents,
        completion: @escaping RequestComponents.ResponseCompletion
    ) {
        let path = requestComponents.path
        do {
            let httpRequest = try HTTPRequestBuilder(requestComponents: requestComponents).build()
            urlSession.dataTask(with: httpRequest) { data, urlResponse, error in
                guard error != nil else {
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
                    do {
                        let decodedData = try JSONDecoder().decode(RequestComponents.Response.self, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(APIError.decoding(url: path)))
                    }
                case 401:
                    // Represents an unauthorized error to provide feedback about wrong email or password
                    completion(.failure(APIError.unauthorized(url: path, statusCode: statusCode)))
                default:
                    completion(.failure(APIError.unknown(url: path)))
                }
            }.resume()
        } catch {
            completion(.failure(APIError.unknown(url: path)))
        }
    }
}

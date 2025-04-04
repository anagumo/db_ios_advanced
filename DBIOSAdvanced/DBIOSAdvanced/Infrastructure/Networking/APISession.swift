import Foundation

protocol APISessionProtocol {
    func request<RequestComponents: HTTPRequestComponents>(_ request: RequestComponents, completion: @escaping RequestComponents.URLResponseCompletion)
}

final class APISession: APISessionProtocol {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request<RequestComponents: HTTPRequestComponents>(_ requestComponents: RequestComponents, completion: @escaping RequestComponents.URLResponseCompletion) {
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

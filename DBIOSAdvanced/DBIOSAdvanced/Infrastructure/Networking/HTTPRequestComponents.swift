import Foundation

protocol HTTPRequestComponents {
    // For URL components
    var host: String { get }
    var path: String { get }
    var queryParameters: [String:String]? { get } // KC API endpoints used in this project does not requiere query params
    // For URL request
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get } // Any type that conforms Encodable protocol
    // For HTTP response
    associatedtype Response: Decodable // The expected type is defined by the type that conforms this protocol
    typealias ResponseCompletion = (Result<Response, APIError>) -> Void // To use it in APISession
}

// MARK: - Default values for HTTP Request Components
extension HTTPRequestComponents {
    var host: String { "dragonball.keepcoding.education" }
    var queryParameters: [String : String]? { [:] }
    var headers: [String : String] { [:] }
    var body: Encodable? { nil }
}

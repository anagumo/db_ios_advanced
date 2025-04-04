import Foundation

protocol HTTPRequestComponents {
    // For url components
    var host: String { get }
    var path: String { get }
    var queryParameters: [String:String]? { get}
    // For url request
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Encodable? { get }
    // For url response
    associatedtype Response: Decodable
    typealias URLResponseCompletion = (Result<Response, APIError>) -> Void
}

extension HTTPRequestComponents {
    var host: String { "dragonball.keepcoding.education" }
    var queryParameters: [String : String]? { [:] }
    var headers: [String : String] { [:] }
    var body: Encodable? { nil }
}

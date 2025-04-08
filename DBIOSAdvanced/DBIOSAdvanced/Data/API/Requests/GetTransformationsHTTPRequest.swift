import Foundation

struct GetTransformationsHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/tranformations"
    var method: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    typealias Response = [TransformationDTO]
    
    init(heroIdentifier: String) {
        body = HTTPBody(id: heroIdentifier)
    }
}

extension GetTransformationsHTTPRequest {
    struct HTTPBody: Encodable {
        let id: String
    }
}

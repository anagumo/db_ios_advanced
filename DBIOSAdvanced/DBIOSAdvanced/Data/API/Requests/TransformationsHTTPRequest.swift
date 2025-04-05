import Foundation

struct TransformationsHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/tranformations"
    var method: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    typealias Response = [TransformationDTO]
    
    init(heroID: String) {
        body = HTTPBody(id: heroID)
    }
}

extension TransformationsHTTPRequest {
    struct HTTPBody: Encodable {
        let id: String
    }
}

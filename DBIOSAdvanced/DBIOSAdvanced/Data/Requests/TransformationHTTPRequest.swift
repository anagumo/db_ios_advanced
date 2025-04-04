import Foundation

struct TransformationHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/tranformations"
    var method: HTTPMethod = .POST
    var body: Encodable?
    typealias Response = [TransformationDTO]
    
    init(heroID: String) {
        body = HTTPBody(id: heroID)
    }
}

extension TransformationHTTPRequest {
    struct HTTPBody: Encodable {
        let id: String
    }
}

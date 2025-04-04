import Foundation

struct HerosHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/all"
    var method: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    typealias Response = [HeroDTO]
    
    init(name: String = "") {
        body = HTTPBoddy(name: name)
    }
}

extension HerosHTTPRequest {
    struct HTTPBoddy: Encodable {
        let name: String
    }
}

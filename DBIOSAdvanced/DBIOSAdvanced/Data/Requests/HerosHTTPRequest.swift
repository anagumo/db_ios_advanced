import Foundation

struct HerosHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/all"
    var method: HTTPMethod = .POST
    var body: Encodable?
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

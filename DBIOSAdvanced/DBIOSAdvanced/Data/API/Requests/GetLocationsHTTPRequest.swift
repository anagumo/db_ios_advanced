import Foundation

struct GetLocationsHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/locations"
    var method: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    typealias Response = [LocationDTO]
    
    init(heroIdentifier: String) {
        body = HTTPBody(id: heroIdentifier)
    }
}

extension GetLocationsHTTPRequest {
    struct HTTPBody: Encodable {
        let id: String
    }
}

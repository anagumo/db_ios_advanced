import Foundation

struct LocationsHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/heros/locations"
    var method: HTTPMethod = .POST
    var body: Encodable?
    var authorized: Bool = true
    typealias Response = [LocationDTO]
    
    init(heroID: String) {
        body = HTTPBody(id: heroID)
    }
}

extension LocationsHTTPRequest {
    struct HTTPBody: Encodable {
        let id: String
    }
}

import Foundation

struct LocationDTO: Decodable {
    let identifier: String
    let longitude: String?
    let latitude: String?
    let date: String?
    let hero: HeroDTO?
    
    enum CodingKeys: String, CodingKey  {
        case identifier = "id"
        case longitude = "longitud"
        case latitude = "latitud"
        case date = "dateShow"
        case hero
    }
}

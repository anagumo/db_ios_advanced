import Foundation

struct LocationDTO: Decodable {
    let id: String
    let longitude: String?
    let latitude: String?
    let date: String?
    let hero: HeroDTO?
    
    enum CodingKeys: String, CodingKey  {
        case id
        case longitude = "longitud"
        case latitude = "latitud"
        case date = "dateShow"
        case hero
    }
}

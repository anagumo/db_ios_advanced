import Foundation

struct TransformationDTO: Decodable {
    let identifier: String
    let name: String?
    let info: String?
    let photo: String?
    let hero: HeroDTO?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case info = "description"
        case photo
        case hero
    }
}

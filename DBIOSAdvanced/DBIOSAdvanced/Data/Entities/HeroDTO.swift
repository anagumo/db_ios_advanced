import Foundation

struct HeroDTO: Decodable {
    let identifier: String
    let name: String?
    let info: String?
    let photo: String?
    let favorite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case info = "description"
        case photo
        case favorite
    }
}

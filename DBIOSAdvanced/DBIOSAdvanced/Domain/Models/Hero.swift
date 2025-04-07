import Foundation

struct Hero: Decodable {
    let identifier: String
    let name: String?
    let info: String?
    let photo: String?
    let favorite: Bool?
}

import Foundation
import SwiftData

@Model
class TransformationEntity {
    @Attribute(.unique)
    var identifier: String
    var name: String?
    var info: String?
    var photo: String?
    var hero: HeroEntity?
    
    init(
        identifier: String,
        name: String? = nil,
        info: String? = nil,
        photo: String? = nil,
        hero: HeroEntity? = nil
    ) {
        self.identifier = identifier
        self.name = name
        self.info = info
        self.photo = photo
        self.hero = hero
    }
}

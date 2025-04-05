import Foundation
import SwiftData

@Model
class HeroEntity {
    @Attribute(.unique)
    var identifier: String
    var name: String?
    var info: String?
    var photo: String?
    var favorite: Bool?
    @Relationship(deleteRule: .cascade, inverse: \TransformationEntity.hero)
    var transformations: [TransformationEntity]?
    @Relationship(deleteRule: .cascade, inverse: \LocationEntity.hero)
    var locations: [LocationEntity]?
    
    init(
        identifier: String,
        name: String? = nil,
        info: String? = nil,
        photo: String? = nil,
        favorite: Bool? = nil,
        transformations: [TransformationEntity]? = nil,
        locations: [LocationEntity]? = nil
    ) {
        self.identifier = identifier
        self.name = name
        self.info = info
        self.photo = photo
        self.favorite = favorite
        self.transformations = transformations
        self.locations = locations
    }
}

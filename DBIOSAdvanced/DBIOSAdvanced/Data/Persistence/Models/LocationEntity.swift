import Foundation
import SwiftData

@Model class LocationEntity {
    @Attribute(.unique) var identifier: String
    var latitude: String?
    var longitude: String?
    var date: String?
    var hero: HeroEntity?
    
    init(
        identifier: String,
        latitude: String? = nil,
        longitude: String? = nil,
        date: String? = nil,
        hero: HeroEntity? = nil
    ) {
        self.identifier = identifier
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.hero = hero
    }
}

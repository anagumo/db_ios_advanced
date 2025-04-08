import Foundation

struct LocationEntityToDomainMapper {
    func map(_ locationEntity: LocationEntity) -> Location? {
        guard let heroEntity = locationEntity.hero else {
            return nil
        }
        
        return Location(
            identifier: locationEntity.identifier,
            longitude: locationEntity.longitude,
            latitude: locationEntity.latitude,
            date: locationEntity.date,
            hero: HeroEntityToDomainMapper().map(heroEntity)
        )
    }
}

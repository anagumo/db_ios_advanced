import Foundation

struct LocationDTOtoEntityMapper {
    func map(_ locationDTO: LocationDTO, relationship: HeroEntity?) -> LocationEntity {
        // Do this without pass the entity should be the same?
        //let heroEntity = HeroDTOtoEntityMapper().map(transformationDTO.hero)
        LocationEntity(
            identifier: locationDTO.identifier,
            latitude: locationDTO.latitude,
            longitude: locationDTO.longitude,
            date: locationDTO.date,
            hero: relationship
        )
    }
}

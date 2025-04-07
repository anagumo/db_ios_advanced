import Foundation

struct HeroEntityToDomainMapper {
    func map(_ heroEntity: HeroEntity) -> Hero {
        Hero(
            identifier: heroEntity.identifier,
            name: heroEntity.name,
            info: heroEntity.info,
            photo: heroEntity.photo,
            favorite: heroEntity.favorite
        )
    }
}

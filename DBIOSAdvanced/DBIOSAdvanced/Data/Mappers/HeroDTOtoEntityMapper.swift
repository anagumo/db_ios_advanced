import Foundation

final class HeroDTOtoEntityMapper {
    func map(_ heroDTO: HeroDTO?) -> HeroEntity {
        HeroEntity(
            identifier: heroDTO?.identifier ?? "",
            name: heroDTO?.name,
            info: heroDTO?.info,
            photo: heroDTO?.photo,
            favorite: heroDTO?.favorite,
            transformations: [],
            locations: []
        )
    }
}

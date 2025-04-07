import Foundation

struct HeroDTOtoDomainMapper {
    func map(_ heroDTO: HeroDTO) -> Hero {
        Hero(
            identifier: heroDTO.identifier,
            name: heroDTO.name,
            info: heroDTO.info,
            photo: heroDTO.photo,
            favorite: heroDTO.favorite
        )
    }
}

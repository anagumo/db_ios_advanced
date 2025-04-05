import Foundation

struct TransformationDTOtoEntityMapper {
    func map(_ transformationDTO: TransformationDTO, relationship: HeroEntity?) -> TransformationEntity {
        // Do this without pass the entity should be the same?
        //let heroEntity = HeroDTOtoEntityMapper().map(transformationDTO.hero)
        TransformationEntity(
            identifier: transformationDTO.identifier,
            name: transformationDTO.name,
            info: transformationDTO.info,
            photo: transformationDTO.photo,
            hero: relationship
        )
    }
}

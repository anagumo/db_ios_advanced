import Foundation

struct TransformationEntityToDomainMapper {
    func map(_ transformationEntity: TransformationEntity) -> Transformation? {
        guard let heroEntity = transformationEntity.hero else {
            return nil
        }
        
        return Transformation(
            identifier: transformationEntity.identifier,
            name: transformationEntity.name,
            info: transformationEntity.info,
            photo: transformationEntity.photo,
            hero: HeroEntityToDomainMapper().map(heroEntity))
    }
}

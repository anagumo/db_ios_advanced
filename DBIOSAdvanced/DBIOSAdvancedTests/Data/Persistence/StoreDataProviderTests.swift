import XCTest
import OSLog
@testable import DBIOSAdvanced

final class StoreDataProviderTests: XCTestCase {
    var sut: StoreDataProvider?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = StoreDataProvider(persistenceType: .memory)
    }
    
    override func tearDownWithError() throws {
        sut?.clearBBDD()
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Hero Cases
    func testInsertHeros() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let initialHeroEntityListCount = try XCTUnwrap(sut?.fetchHeros().count)
        
        // When
        sut?.insertHeros(heroDTOList)
        let heroEntityList = try XCTUnwrap(sut?.fetchHeros())
        
        // Then
        let finalHeroEntityListCount = heroEntityList.count
        let firstHeroEntity = try XCTUnwrap(heroEntityList.first)
        XCTAssertNotEqual(initialHeroEntityListCount, finalHeroEntityListCount)
        XCTAssertEqual(firstHeroEntity.name, "Bulma")
        XCTAssertEqual(firstHeroEntity.info, "Sobran las presentaciones cuando se habla de Bulma.")
        XCTAssertEqual(firstHeroEntity.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2021/01/Bulma-Dragon-Ball.jpg?width=300")
        XCTAssertEqual(firstHeroEntity.favorite, false)
    }
    
    func testFetchHeros() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        
        // When
        sut?.insertHeros(heroDTOList)
        let heroEntityList = try XCTUnwrap(sut?.fetchHeros())
        let heroEntityB = try XCTUnwrap(sut?.fetchHeros(sortAscending: false).first)
        
        // Then
        XCTAssertEqual(heroEntityList.count, 5)
        XCTAssertEqual(heroEntityB.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE95")
        XCTAssertEqual(heroEntityB.name, "Vegeta")
        XCTAssertEqual(heroEntityB.info, "Sobran las presentaciones cuando se habla de Vegeta.")
        XCTAssertEqual(heroEntityB.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/vegeta1.jpg?width=300")
        XCTAssertEqual(heroEntityB.favorite, true)
    }
    
    func testFetchHeros_ShouldReturnError() throws {
        // Given
        let heroDTOList: [HeroDTO] = []
        
        // When
        sut?.insertHeros(heroDTOList)
        let heroEntityList = sut?.fetchHeros()
        
        // Then
        XCTAssertEqual(heroEntityList?.count, 0)
        XCTAssertNil(heroEntityList?.first)
    }
    
    func testFetchHero() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        
        // When
        sut?.insertHeros(heroDTOList)
        let heroEntityA = try XCTUnwrap(sut?.fetchHero(name: "Bulma"))
        let heroEntityB = try XCTUnwrap(sut?.fetchHero(identifier: "64143856-12D8-4EF9-9B6F-F08742098A18"))
        
        // Then
        XCTAssertEqual(heroEntityA.identifier, "64143856-12D8-4EF9-9B6F-F08742098A18")
        XCTAssertEqual(heroEntityB.name, "Bulma")
    }
    
    func testFetchHero_ShouldReturnError() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        
        // When
        sut?.insertHeros(heroDTOList)
        let heroEntity = sut?.fetchHero(name: "Gohan") // :(
        
        //Then
        XCTAssertNil(heroEntity)
    }
    
    // MARK: - Transformation Cases
    func testInsertTransformations() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let transformationDTOList = TransformationData.givenDTOList
        
        // When
        sut?.insertHeros(heroDTOList)
        sut?.insertTransformations(transformationDTOList)
        let heroEntityA = try XCTUnwrap(sut?.fetchHero(name: "Goku"))
        let heroEntityB = try XCTUnwrap(sut?.fetchHero(name: "Piccolo"))
        let transformationEntityListA = try XCTUnwrap(sut?.fetchTransformations(heroIdentifier: heroEntityA.identifier))
        
        // Then
        XCTAssertNotEqual(heroEntityA.transformations?.count, heroEntityB.transformations?.count)
        XCTAssertEqual(heroEntityA.transformations?.count, 3)
        XCTAssertEqual(transformationEntityListA.count, 3)
        XCTAssertEqual(heroEntityB.transformations?.count, 0)
    }
    
    func testFetchTransformations() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let transformationDTOList = TransformationData.givenDTOList
        let heroDTO = try XCTUnwrap(heroDTOList.filter { $0.name == "Goku" }.first)
        
        // When
        sut?.insertHeros(heroDTOList)
        sut?.insertTransformations(transformationDTOList)
        let transformationEntityList = sut?.fetchTransformations(heroIdentifier: heroDTO.identifier)
        
        // Then
        XCTAssertEqual(transformationEntityList?.count, 3)
        XCTAssertNotNil(transformationEntityList?.first)
        XCTAssertEqual(transformationEntityList?.first?.identifier, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        XCTAssertEqual(transformationEntityList?.first?.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformationEntityList?.first?.photo, "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")
        XCTAssertEqual(transformationEntityList?.first?.hero?.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
    }
    
    func testFetchTransformations_ShouldReturnError() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let heroDTO = try XCTUnwrap(heroDTOList.filter { $0.name == "Piccolo" }.first)
        
        // When
        sut?.insertHeros(heroDTOList)
        let transformationEntityList = sut?.fetchTransformations(heroIdentifier: heroDTO.identifier)
        
        // Then
        XCTAssertEqual(transformationEntityList?.count, 0)
        XCTAssertNil(transformationEntityList?.first)
    }
    
    func testFetchTransformation() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let transformationDTOList = TransformationData.givenDTOList
        let transformationDTO = try XCTUnwrap(transformationDTOList.filter { $0.identifier == "EE4DEC64-1B2D-47C1-A8EA-3208894A57A6" }.first)
        
        // When
        sut?.insertHeros(heroDTOList)
        sut?.insertTransformations(transformationDTOList)
        let transformationEntity = sut?.fetchTransformation(identifier: transformationDTO.identifier)
        
        // Then
        XCTAssertNotNil(transformationEntity)
        XCTAssertEqual(transformationEntity?.identifier, "EE4DEC64-1B2D-47C1-A8EA-3208894A57A6")
        XCTAssertEqual(transformationEntity?.name, "3. Super Saiyan Blue")
        XCTAssertEqual(transformationEntity?.photo, "https://areajugones.sport.es/wp-content/uploads/2015/10/super_saiyan_god_super_saiyan__ssgss__goku_by_mikkkiwarrior3-d8wv7hx.jpg")
        XCTAssertEqual(transformationEntity?.hero?.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
    }
    
    func testFetchTransformation_ShouldReturnError() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let heroDTO = try XCTUnwrap(heroDTOList.filter { $0.name == "Piccolo" }.first)
        
        // When
        sut?.insertHeros(heroDTOList)
        let transformationEntity = sut?.fetchTransformation(identifier: heroDTO.identifier)
        
        // Then
        XCTAssertNil(transformationEntity)
    }
    
    // MARK: - Location Cases
    func testInsertLocations() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let locationDTOList = LocationData.givenDTOList
        
        // When
        sut?.insertHeros(heroDTOList)
        sut?.insertLocations(locationDTOList)
        let heroEntityA = try XCTUnwrap(sut?.fetchHero(name: "Goku"))
        let heroEntityB = try XCTUnwrap(sut?.fetchHero(name: "Piccolo"))
        let locationEntityListB = try XCTUnwrap(heroEntityB.locations)
        
        // Then
        XCTAssertNotEqual(heroEntityA.locations?.count, heroEntityB.locations?.count)
        XCTAssertEqual(heroEntityB.locations?.count, 1)
        XCTAssertEqual(locationEntityListB.count, 1)
        XCTAssertEqual(locationEntityListB.first?.latitude, "36.1251954")
        XCTAssertEqual(locationEntityListB.first?.longitude, "-115.3154276")
        XCTAssertEqual(locationEntityListB.first?.date, "2022-09-26T00:00:00Z")
    }
    
    func testFetchLocations() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let locationDTOList = LocationData.givenDTOList
        let heroDTO = try XCTUnwrap(heroDTOList.filter { $0.name == "Piccolo" }.first)
        
        // When
        sut?.insertHeros(heroDTOList)
        sut?.insertLocations(locationDTOList)
        let locationEntityList = sut?.fetchLocations(heroIdentifier: heroDTO.identifier)
        let heroEntity = sut?.fetchHero(name: heroDTO.name)
        
        // Then
        XCTAssertEqual(locationEntityList?.count, heroEntity?.locations?.count)
        XCTAssertEqual(locationEntityList?.count, 1)
        XCTAssertEqual(heroEntity?.locations?.count, 1)
        XCTAssertEqual(locationEntityList?.first?.hero?.identifier, heroDTO.identifier)
    }
    
    func testFetchLocations_ShouldReturnError() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let heroDTO = try XCTUnwrap(heroDTOList.filter { $0.name == "Piccolo" }.first)
        
        // When
        sut?.insertHeros(heroDTOList)
        let locationEntityList = sut?.fetchLocations(heroIdentifier: heroDTO.identifier)
        
        // Then
        XCTAssertEqual(locationEntityList?.count, 0)
        XCTAssertNil(locationEntityList?.first)
    }
    
    func testClearBBDD() throws {
        // Given
        let heroDTOList = HeroData.givenDTOList
        let locationDTOList = LocationData.givenDTOList
        
        // When
        sut?.insertHeros(heroDTOList)
        sut?.insertLocations(locationDTOList)
        let heroEntityListBefore = try XCTUnwrap(sut?.fetchHeros())
        let locationEntityListBefore = try XCTUnwrap(sut?.fetchLocations(heroIdentifier: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A06"))
        sut?.clearBBDD()
        let heroEntityListAfter = try XCTUnwrap(sut?.fetchHeros())
        let locationEntityListAfter = try XCTUnwrap(sut?.fetchLocations(heroIdentifier: "CBCFBDEC-F89B-41A1-AC0A-FBDA66A33A06"))
        
        // Then
        XCTAssertNotEqual(heroEntityListBefore.count, heroEntityListAfter.count)
        XCTAssertEqual(heroEntityListBefore.count, 5, "Heros before clear")
        XCTAssertEqual(heroEntityListAfter.count, 0, "Heros after clear")
        XCTAssertNotEqual(locationEntityListBefore.count, locationEntityListAfter.count)
        XCTAssertEqual(locationEntityListBefore.count, 1, "Locations before clear")
        XCTAssertEqual(locationEntityListAfter.count, 0, "Locations after clear")
    }
}

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
        let herosDTOList = HeroDTOList.givenHeroDTOList
        let initialHeroEntityListCount = try XCTUnwrap(sut?.fetchHeros().count)
        
        // When
        sut?.insertHeros(herosDTOList)
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
    
    // MARK: - Transformation Cases
    func testInsertTransformations() throws {
        // Given
        let herosDTOList = HeroDTOList.givenHeroDTOList
        let transformationsDTOList = TransformationDTOList.giveTransformatioDTOList
        
        // When
        sut?.insertHeros(herosDTOList)
        sut?.insertTransformations(transformationsDTOList)
        let heroEntityA = try XCTUnwrap(sut?.fetchHeros(name: "Goku").first)
        let heroEntityB = try XCTUnwrap(sut?.fetchHeros(name: "Piccolo").first)
        let transformationEntityListA = try XCTUnwrap(sut?.fetchTransformations(heroIdentifier: heroEntityA.identifier))
        
        // Then
        XCTAssertNotEqual(heroEntityA.transformations?.count, heroEntityB.transformations?.count)
        XCTAssertEqual(heroEntityA.transformations?.count, 3)
        XCTAssertEqual(transformationEntityListA.count, 3)
        XCTAssertEqual(transformationEntityListA.first?.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformationEntityListA.first?.photo, "https://areajugones.sport.es/wp-content/uploads/2017/05/Goku_Kaio-Ken_Coolers_Revenge.jpg")
        XCTAssertEqual(transformationEntityListA.first?.hero?.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
    }
    
    // MARK: - Location Cases
    func testInsertLocations() throws {
        // Given
        let herosDTOList = HeroDTOList.givenHeroDTOList
        let locationsDTOList = LocationDTOList.giveLocationDTOList
        
        // When
        sut?.insertHeros(herosDTOList)
        sut?.insertLocations(locationsDTOList)
        let heroEntityA = try XCTUnwrap(sut?.fetchHeros(name: "Goku").first)
        let heroEntityB = try XCTUnwrap(sut?.fetchHeros(name: "Piccolo").first)
        let locationEntityListB = try XCTUnwrap(heroEntityB.locations)
        
        // Then
        XCTAssertNotEqual(heroEntityA.locations?.count, heroEntityB.locations?.count)
        XCTAssertEqual(heroEntityB.locations?.count, 1)
        XCTAssertEqual(locationEntityListB.count, 1)
        XCTAssertEqual(locationEntityListB.first?.latitude, "36.1251954")
        XCTAssertEqual(locationEntityListB.first?.longitude, "-115.3154276")
        XCTAssertEqual(locationEntityListB.first?.date, "2022-09-26T00:00:00Z")
    }
}

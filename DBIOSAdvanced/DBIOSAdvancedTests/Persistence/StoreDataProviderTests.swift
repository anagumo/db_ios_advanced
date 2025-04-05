import XCTest
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
}

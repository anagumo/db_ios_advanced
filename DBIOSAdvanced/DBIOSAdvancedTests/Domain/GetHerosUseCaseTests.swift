import Foundation
import XCTest
@testable import DBIOSAdvanced

final class GetHerosUseCaseTests: XCTestCase {
    var sut: GetHerosUseCase!
    var mockStoreDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: urlSessionConfiguration)
        let mockAPISession = APISession(urlSession: mockURLSession)
        mockStoreDataProvider = StoreDataProvider(persistenceType: .memory)
        
        sut = GetHerosUseCase(
            storeDataProvider: mockStoreDataProvider,
            apiSession: mockAPISession)
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        mockStoreDataProvider.clearBBDD()
        mockStoreDataProvider = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetHeros_WhenLocalIsEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get heros from remote suceed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: GetHerosUseCaseTests.self).url(forResource: "Heros", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let localHeroEntityListBefore = mockStoreDataProvider.fetchHeros()
        var receivedResponse: [Hero]?
        sut.run { result in
            do {
                let heroList = try result.get()
                receivedResponse = heroList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedRequest)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/all")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(localHeroEntityListBefore.count, 0)
        let localHeroEntityListAfter = mockStoreDataProvider.fetchHeros()
        XCTAssertEqual(localHeroEntityListAfter.count, 15)
        XCTAssertEqual(receivedResponse?.count, 15)
        let hero = try XCTUnwrap(receivedResponse?.first)
        XCTAssertEqual(hero.identifier, "963CA612-716B-4D08-991E-8B1AFF625A81")
        XCTAssertEqual(hero.name, "Androide 17")
        XCTAssertEqual(hero.info, "Es el hermano gemelo de Androide 18. Son muy parecidos físicamente, aunque Androide 17 es un joven moreno. También está programado para destruir a Goku porque fue el responsable de exterminar el Ejército Red Ribbon. Sin embargo, mató a su creador el Dr. Gero por haberle convertido en un androide en contra de su voluntad. Es un personaje con mucha confianza en sí mismo, sarcástico y rebelde que no se deja pisotear. Ese exceso de confianza le hace cometer errores que pueden costarle la vida")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2019/10/dragon-ball-androide-17.jpg?width=300")
        XCTAssertEqual(hero.favorite, true)
    }
    
    func testGetHeros_WhenLocalIsNotEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get heros from local succeed")
        let heroDTOList = HeroDTOData.givenList
        mockStoreDataProvider.insertHeros(heroDTOList)
        
        // When
        var receivedResponse: [Hero]?
        sut.run { result in
            do {
                let heroList = try result.get()
                receivedResponse = heroList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        //Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.count, 5)
        let hero = try XCTUnwrap(receivedResponse?.first)
        XCTAssertEqual(hero.identifier, "64143856-12D8-4EF9-9B6F-F08742098A18")
        XCTAssertEqual(hero.name, "Bulma")
        XCTAssertEqual(hero.info, "Sobran las presentaciones cuando se habla de Bulma.")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2021/01/Bulma-Dragon-Ball.jpg?width=300")
        XCTAssertEqual(hero.favorite, false)
    }
}

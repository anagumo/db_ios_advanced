import Foundation
import XCTest
@testable import DBIOSAdvanced

final class GetTransformationsUseCaseTests: XCTestCase {
    var sut: GetTransformationsUseCaseProtocol!
    var mockStoreDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: urlSessionConfiguration)
        let mockAPISession = APISession(urlSession: mockURLSession)
        mockStoreDataProvider = StoreDataProvider(persistenceType: .memory)
        sut = TransformationsUseCase(
            storeDataProvider: mockStoreDataProvider,
            apiSession: mockAPISession
        )
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        mockStoreDataProvider.clearBBDD()
        mockStoreDataProvider = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetTransformations_WhenLocalIsEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get transformations from remote suceed")
        let heroDTO = try XCTUnwrap(HeroDTOData.givenList.filter { $0.name == "Goku" }.first)
        mockStoreDataProvider.insertHeros([heroDTO])
        
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: GetTransformationsUseCaseTests.self).url(forResource: "Transformations", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let localTransformationEntityListBefore = mockStoreDataProvider.fetchLocations(heroIdentifier: heroDTO.identifier)
        var receivedResponse: [Transformation]?
        sut.run(heroIdentifer: heroDTO.identifier) { result in
            do {
                let transformationList = try result.get()
                receivedResponse = transformationList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedRequest)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/tranformations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(localTransformationEntityListBefore.count, 0)
        let localTransformationEntityListAfter = mockStoreDataProvider.fetchTransformations(heroIdentifier: heroDTO.identifier)
        XCTAssertEqual(localTransformationEntityListAfter.count, 14)
        XCTAssertEqual(receivedResponse?.count, 14)
        let transformation = try XCTUnwrap(receivedResponse?.first)
        XCTAssertEqual(transformation.identifier, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        XCTAssertEqual(transformation.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformation.info, "Cómo todos los Saiyans con cola, Goku es capaz de convertirse en un mono gigante si mira fijamente a la luna llena. Así es como Goku cuando era un infante liberaba todo su potencial a cambio de perder todo el raciocinio y transformarse en una auténtica bestia. Es por ello que sus amigos optan por cortarle la cola para que no ocurran desgracias, ya que Goku mató a su propio abuelo adoptivo Son Gohan estando en este estado. Después de beber el Agua Ultra Divina, Goku liberó todo su potencial sin necesidad de volver a convertirse en Oozaru")
        XCTAssertEqual(transformation.photo, "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")
        XCTAssertEqual(transformation.hero?.identifier, heroDTO.identifier)
    }
    
    func testGetTransformations_WhenLocalIsNotEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get transformations from local succeed")
        let heroDTO = try XCTUnwrap(HeroDTOData.givenList.filter { $0.name == "Goku" }.first)
        let transformationDTOList = TransformationDTOData.givenList
        mockStoreDataProvider.insertHeros([heroDTO])
        mockStoreDataProvider.insertTransformations(transformationDTOList)
        
        // When
        var receivedResponse: [Transformation]?
        sut.run(heroIdentifer: heroDTO.identifier) { result in
            do {
                let transformationList = try result.get()
                receivedResponse = transformationList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        //Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.count, 3)
        let transformation = try XCTUnwrap(receivedResponse?.first)
        XCTAssertEqual(transformation.identifier, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        XCTAssertEqual(transformation.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformation.info, "Cómo todos los Saiyans con cola, Goku es capaz de convertirse en un mono gigante si mira fijamente a la luna llena. Así es como Goku cuando era un infante liberaba todo su potencial a cambio de perder todo el raciocinio y transformarse en una auténtica bestia. Es por ello que sus amigos optan por cortarle la cola para que no ocurran desgracias, ya que Goku mató a su propio abuelo adoptivo Son Gohan estando en este estado. Después de beber el Agua Ultra Divina, Goku liberó todo su potencial sin necesidad de volver a convertirse en Oozaru")
        XCTAssertEqual(transformation.photo, "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")
        XCTAssertEqual(transformation.hero?.identifier, heroDTO.identifier)
    }
    
    func testGetTransformations_WhenInvalidIdentifier_ShouldReturnEmptyError() throws {
        // Given
        let failureExpectation = expectation(description: "Get transformations form remote failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: GetTransformationsUseCaseTests.self).url(forResource: "EmptyList", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedError: PresentationError?
        sut.run(heroIdentifer: "hero.identifier") { result in
            do {
                let _ = try result.get()
                XCTFail("Waiting for failure")
            } catch let error as PresentationError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("Waiting for hero error")
            }
        }
        
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .emptyList())
        XCTAssertEqual(receivedError?.reason, "Empty entity list")
    }
}


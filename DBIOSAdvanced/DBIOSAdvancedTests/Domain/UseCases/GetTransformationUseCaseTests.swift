import XCTest
@testable import DBIOSAdvanced

final class GetTransformationUseCaseTests: XCTestCase {
    var sut: GetTransformationUseCase!
    var mockStoreDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockStoreDataProvider = StoreDataProvider(persistenceType: .memory)
        sut = GetTransformationUseCase(storeDataProvider: mockStoreDataProvider)
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        mockStoreDataProvider.clearBBDD()
        mockStoreDataProvider = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testGetTransformation_WhenLocalIsNotEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get transformations from local succeed")
        let heroDTO = try XCTUnwrap(HeroData.givenDTOList.filter { $0.name == "Goku" }.first)
        let transformationDTOList = TransformationData.givenDTOList
        let transformationDTO = try XCTUnwrap(transformationDTOList.first)
        mockStoreDataProvider.insertHeros([heroDTO])
        mockStoreDataProvider.insertTransformations(transformationDTOList)
        
        // When
        var receivedResponse: Transformation?
        sut.run(identifer: transformationDTO.identifier) { result in
            do {
                let transformation = try result.get()
                receivedResponse = transformation
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        //Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedResponse)
        let transformation = try XCTUnwrap(receivedResponse)
        XCTAssertEqual(transformation.identifier, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        XCTAssertEqual(transformation.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformation.info, "Cómo todos los Saiyans con cola, Goku es capaz de convertirse en un mono gigante si mira fijamente a la luna llena. Así es como Goku cuando era un infante liberaba todo su potencial a cambio de perder todo el raciocinio y transformarse en una auténtica bestia. Es por ello que sus amigos optan por cortarle la cola para que no ocurran desgracias, ya que Goku mató a su propio abuelo adoptivo Son Gohan estando en este estado. Después de beber el Agua Ultra Divina, Goku liberó todo su potencial sin necesidad de volver a convertirse en Oozaru")
        XCTAssertEqual(transformation.photo, "https://areajugones.sport.es/wp-content/uploads/2021/05/ozarru.jpg.webp")
        XCTAssertEqual(transformation.hero?.identifier, heroDTO.identifier)
    }
    
    func testGetTransformation_WhenLocalIsEmpty_ShouldReturnError() throws {
        // Given
        let failureExpectation = expectation(description: "Get transformations form local failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: GetTransformationsUseCaseTests.self).url(forResource: "EmptyList", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedError: PresentationError?
        sut.run(identifer: "transformation.identifier") { result in
            do {
                let _ = try result.get()
                XCTFail("Waiting for failure")
            } catch let error as PresentationError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("Waiting for app error")
            }
        }
        
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .notFound())
        XCTAssertEqual(receivedError?.reason, "Entity not found")
    }
}


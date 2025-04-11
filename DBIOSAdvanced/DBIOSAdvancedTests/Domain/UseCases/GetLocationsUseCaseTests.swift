import XCTest
@testable import DBIOSAdvanced

final class GetLocationsUseCaseTests: XCTestCase {
    var sut: GetLocationsUseCaseProtocol!
    var mockStoreDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: urlSessionConfiguration)
        let mockAPISession = APISession(urlSession: mockURLSession)
        mockStoreDataProvider = StoreDataProvider(persistenceType: .memory)
        sut = GetLocationsUseCase(
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
    
    func testGetLocations_WhenLocalIsEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get locations from remote suceed")
        let heroDTO = try XCTUnwrap(HeroDTOData.givenList.filter { $0.name == "Piccolo" }.first)
        mockStoreDataProvider.insertHeros([heroDTO])
        
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: GetLocationsUseCaseTests.self).url(forResource: "Locations", withExtension: "json"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        let localEntityListBefore = mockStoreDataProvider.fetchLocations(heroIdentifier: heroDTO.identifier)
        var receivedResponse: [Location]?
        sut.run(heroIdentifer: heroDTO.identifier) { result in
            do {
                let locationList = try result.get()
                receivedResponse = locationList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedRequest)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/heros/locations")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(localEntityListBefore.count, 0)
        let localEntityListAfter = mockStoreDataProvider.fetchLocations(heroIdentifier: heroDTO.identifier)
        XCTAssertEqual(localEntityListAfter.count, 1)
        XCTAssertEqual(receivedResponse?.count, 1)
        let location = try XCTUnwrap(receivedResponse?.first)
        XCTAssertEqual(location.identifier, "ACB5ABB7-8C85-4A0F-872C-5467EDD23D7F")
        XCTAssertEqual(location.latitude, "36.1251954")
        XCTAssertEqual(location.longitude, "-115.3154276")
        XCTAssertEqual(location.date, "2022-09-26T00:00:00Z")
        XCTAssertEqual(location.hero?.identifier, heroDTO.identifier)
    }

    
    func testGetLocations_WhenLocalIsNotEmpty_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Get locations from local succeed")
        let heroDTO = try XCTUnwrap(HeroDTOData.givenList.filter { $0.name == "Piccolo" }.first)
        let locationDTOList = LocationDTOData.givenList
        mockStoreDataProvider.insertHeros([heroDTO])
        mockStoreDataProvider.insertLocations(locationDTOList)
        
        // When
        var receivedResponse: [Location]?
        sut.run(heroIdentifer: heroDTO.identifier) { result in
            do {
                let locationList = try result.get()
                receivedResponse = locationList
                successExpectation.fulfill()
            } catch {
                XCTFail("Waiting for success")
            }
        }
        
        //Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedResponse)
        XCTAssertEqual(receivedResponse?.count, 1)
        let location = try XCTUnwrap(receivedResponse?.first)
        XCTAssertEqual(location.identifier, "ACB5ABB7-8C85-4A0F-872C-5467EDD23D7F")
        XCTAssertEqual(location.latitude, "36.1251954")
        XCTAssertEqual(location.longitude, "-115.3154276")
        XCTAssertEqual(location.date, "2022-09-26T00:00:00Z")
        XCTAssertEqual(location.hero?.identifier, heroDTO.identifier)
    }
    
    func testGetLocation_WhenInvalidIdentifier_ShouldReturnEmptyError() throws {
        // Given
        let failureExpectation = expectation(description: "Get locations form remote failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: GetLocationsUseCaseTests.self).url(forResource: "EmptyList", withExtension: "json"))
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



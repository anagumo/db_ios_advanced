import XCTest
@testable import DBIOSAdvanced

final class HeroViewModelTests: XCTestCase {
    var sut: HeroDetailViewModel!
    var mockGetHerosUseCase: MockGetHerosUseCase!
    var mockGetLocationsUseCase: MockGetLocationsUseCase!
    var mockGetTransformationsUseCase: MockGetTransformationsUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetHerosUseCase = MockGetHerosUseCase()
        mockGetLocationsUseCase = MockGetLocationsUseCase()
        mockGetTransformationsUseCase = MockGetTransformationsUseCase()
        sut = HeroDetailViewModel(
            name: "Piccolo",
            getHerosUseCase: mockGetHerosUseCase,
            getLocationsUseCase: mockGetLocationsUseCase,
            getTransformationsUseCase: mockGetTransformationsUseCase
        )
        
        let hero = HeroDTOData.givenDomainList.filter { $0.name == "Piccolo" }
        mockGetHerosUseCase.receivedResponse = hero
        let locations = LocationDTOData.givenDomainList
        mockGetLocationsUseCase.receivedResponse = locations
        mockGetTransformationsUseCase.receivedResponse = []
    }
    
    override func tearDownWithError() throws {
        mockGetHerosUseCase = nil
        mockGetLocationsUseCase = nil
        mockGetTransformationsUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoad_WhenStateIsReady() throws {
        // Given
        let readyExpectation = expectation(description: "Ready state succeed")
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .ready:
                readyExpectation.fulfill()
            default:
                XCTFail("Waiting for ready state")
            }
        }
        sut.load()
        
        // Then
        wait(for: [readyExpectation], timeout: 0.1)
        XCTAssertNotNil(sut.get())
        let hero = try XCTUnwrap(sut.get())
        XCTAssertEqual(hero.name, "Piccolo")
    }
    
    func testLoadLocations_WhenStateIsLocations() throws {
        // Given
        let readyExpectation = expectation(description: "Ready state succeed")
        let locationsExpectation = expectation(description: "Locations state succeed")
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .ready:
                readyExpectation.fulfill()
            case .locations:
                locationsExpectation.fulfill()
            default:
                XCTFail("Waiting for locations state")
            }
        }
        sut.load()
        sut.loadLocations()
        
        // Then
        wait(for: [readyExpectation, locationsExpectation], timeout: 0.1)
        XCTAssertNotEqual(sut.getMapAnnotations(), [])
        XCTAssertNotNil(sut.getMapRegion())
        let mapAnnotations = try XCTUnwrap(sut.getMapAnnotations())
        let mapRegion = try XCTUnwrap(sut.getMapRegion())
        XCTAssertEqual(mapAnnotations.count, 1)
        XCTAssertEqual(mapAnnotations.first?.title, "Piccolo")
        XCTAssertEqual(mapRegion.center.latitude, mapAnnotations.first?.coordinate.latitude)
        XCTAssertEqual(mapRegion.center.longitude, mapAnnotations.first?.coordinate.longitude)
    }
    
    func testLoadTransformations_WhenTransformationsAreEmpty() throws {
        // Given
        let readyExpectation = expectation(description: "Ready state succeed")
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .ready:
                readyExpectation.fulfill()
            default:
                XCTFail("Waiting for transformations empty state")
            }
        }
        sut.load()
        sut.loadTransformations()
        
        // Then
        wait(for: [readyExpectation], timeout: 0.1)
        // Piccolo has not transformations and there is not a change of state
        XCTAssertEqual(sut.getTransformations(), [])
        XCTAssertNil(sut.getTransformation(0))
    }
}

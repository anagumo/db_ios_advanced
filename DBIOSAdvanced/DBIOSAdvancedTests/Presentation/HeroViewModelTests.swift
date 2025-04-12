import XCTest
@testable import DBIOSAdvanced

final class HeroViewModelTests: XCTestCase {
    var sut: HeroViewModel!
    var mockGetHerosUseCase: MockGetHerosUseCase!
    var mockGetLocationsUseCase: MockGetLocationsUseCase!
    var mockGetTransformationsUseCase: MockGetTransformationsUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetHerosUseCase = MockGetHerosUseCase()
        mockGetLocationsUseCase = MockGetLocationsUseCase()
        mockGetTransformationsUseCase = MockGetTransformationsUseCase()
        sut = HeroViewModel(
            name: "Piccolo",
            getHerosUseCase: mockGetHerosUseCase,
            getLocationsUseCase: mockGetLocationsUseCase,
            getTransformationsUseCase: mockGetTransformationsUseCase
        )
        
        let hero = HeroData.givenDomainList.filter { $0.name == "Piccolo" }
        mockGetHerosUseCase.receivedResponse = hero
        let locations = LocationData.givenDomainList
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
    
    func testLoad_WhenStateIsError() {
        // Given
        let errorExpectation = expectation(description: "Error state succeed")
        mockGetHerosUseCase.receivedResponse = nil
        mockGetLocationsUseCase.receivedResponse = nil
        mockGetTransformationsUseCase.receivedResponse = nil
        
        // When
        var receivedError: String?
        sut.onStateChanged.bind { state in
            switch state {
            case let .error(message):
                receivedError = message
                errorExpectation.fulfill()
            default:
                XCTFail("Waiting for error state")
            }
        }
        sut.load()
        
        // Then
        wait(for: [errorExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, "No data received")
        XCTAssertNil(sut.get())
        XCTAssertEqual(sut.getMapAnnotations(), [])
        XCTAssertEqual(sut.getTransformations(), [])
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
                XCTFail("Waiting for empty transformations")
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
    
    func testLoadTransformations_WhenStateIsTransformations() throws {
        // Given
        let readyExpectation = expectation(description: "Ready state succeed")
        let transformationsExpectation = expectation(description: "Transformation state succeed")
        let hero = HeroData.givenDomainList.filter { $0.name == "Goku" }
        mockGetHerosUseCase.receivedResponse = hero
        let transformations = TransformationData.givenDomainList
        mockGetLocationsUseCase.receivedResponse = nil
        mockGetTransformationsUseCase.receivedResponse = transformations
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .ready:
                readyExpectation.fulfill()
            case .transformations:
                transformationsExpectation.fulfill()
            default:
                XCTFail("Waiting for empty transformations")
            }
        }
        sut.load()
        sut.loadLocations()
        sut.loadTransformations()
        
        // Then
        wait(for: [readyExpectation, transformationsExpectation], timeout: 0.1)
        XCTAssertEqual(sut.getMapAnnotations(), [])
        XCTAssertNil(sut.getMapRegion())
        XCTAssertEqual(sut.getTransformations().count, 3)
        XCTAssertNotNil(sut.getTransformation(0))
        let transformation = try XCTUnwrap(sut.getTransformation(0))
        XCTAssertEqual(transformation.identifier, "17824501-1106-4815-BC7A-BFDCCEE43CC9")
        XCTAssertEqual(transformation.name, "1. Oozaru – Gran Mono")
        XCTAssertEqual(transformation.hero?.identifier, hero.first?.identifier)
    }
}

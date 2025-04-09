import Foundation
import XCTest
@testable import DBIOSAdvanced

final class HerosModelViewTests: XCTestCase {
    var sut: HerosViewModel!
    var mockHerosUseCase: MockHerosUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockHerosUseCase = MockHerosUseCase()
        sut = HerosViewModel(herosUseCase: mockHerosUseCase)
    }
    
    override func tearDownWithError() throws {
        mockHerosUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadHeros_WhenStateIsReady() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let readyExpectation = expectation(description: "Ready state succeed")
        let heroDTOList = HeroDTOData.givenList
        let heroList = heroDTOList.compactMap { HeroDTOtoDomainMapper().map($0) }
        mockHerosUseCase.receivedResponse = heroList
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                readyExpectation.fulfill()
            case .error:
                XCTFail("Waiting for ready")
            }
        }
        sut.load()
        
        // Then
        wait(for: [loadingExpectation, readyExpectation], timeout: 0.1)
        XCTAssert(!sut.getAll().isEmpty)
        XCTAssertEqual(sut.getCount(), 5)
        let hero = try XCTUnwrap(sut.getHero(position: 0))
        XCTAssertEqual(hero.identifier, "D13A40E5-4418-4223-9CE6-D2F9A28EBE94")
        XCTAssertEqual(hero.name, "Goku")
        XCTAssertEqual(hero.info, "Sobran las presentaciones cuando se habla de Goku.")
        XCTAssertEqual(hero.photo, "https://cdn.alfabetajuega.com/alfabetajuega/2020/12/goku1.jpg?width=300")
        XCTAssertEqual(hero.favorite, false)
    }
    
    func testLoadHeros_WhenStateIsError() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let errorExpectation = expectation(description: "Error state succeed")
        
        // When
        var receivedErrorReason: String?
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                XCTFail("Waiting for error")
            case .error(let reason):
                receivedErrorReason = reason
                errorExpectation.fulfill()
            }
        }
        sut.load()
        
        // Then
        wait(for: [loadingExpectation, errorExpectation], timeout: 0.1)
        XCTAssertEqual(receivedErrorReason, "No data received")
        XCTAssert(sut.getAll().isEmpty)
        XCTAssertEqual(sut.getCount(), 0)
        XCTAssertNil(sut.getHero(position: 0))
    }
    
    func testLoadHeros_WhenStateIsEmptyError() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let errorExpectation = expectation(description: "Error state succeed")
        mockHerosUseCase.receivedResponse = []
        
        // When
        var receivedErrorReason: String?
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                XCTFail("Waiting for error")
            case .error(let reason):
                receivedErrorReason = reason
                errorExpectation.fulfill()
            }
        }
        sut.load()
        
        // Then
        wait(for: [loadingExpectation, errorExpectation], timeout: 0.1)
        XCTAssertEqual(receivedErrorReason, "Empty entity list")
        XCTAssert(sut.getAll().isEmpty)
        XCTAssertEqual(sut.getCount(), 0)
        XCTAssertNil(sut.getHero(position: 0))
    }
}

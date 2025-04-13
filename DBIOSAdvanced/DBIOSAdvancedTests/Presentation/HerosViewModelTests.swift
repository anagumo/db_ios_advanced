import XCTest
@testable import DBIOSAdvanced

final class HerosViewModelTests: XCTestCase {
    var sut: HerosViewModel!
    var mockHerosUseCase: MockGetHerosUseCase!
    var mockLogoutUseCase: MockLogoutUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockHerosUseCase = MockGetHerosUseCase()
        mockLogoutUseCase = MockLogoutUseCase()
        sut = HerosViewModel(
            herosUseCase: mockHerosUseCase,
            // Use case not mocked since is part of optional features
            sortHerosUseCase: SortHerosUseCase(
                storeDataProvider: .init(persistenceType: .memory)
            ),
            logoutUseCase: mockLogoutUseCase
        )
    }
    
    override func tearDownWithError() throws {
        mockHerosUseCase = nil
        mockLogoutUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoadHeros_WhenStateIsReady() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let readyExpectation = expectation(description: "Ready state succeed")
        let heroDTOList = HeroData.givenDTOList
        let heroList = heroDTOList.compactMap { HeroDTOtoDomainMapper().map($0) }
        mockHerosUseCase.receivedResponse = heroList
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                readyExpectation.fulfill()
            default:
                XCTFail("Waiting for ready")
            }
        }
        sut.load()
        
        // Then
        wait(for: [loadingExpectation, readyExpectation], timeout: 0.1)
        XCTAssert(!sut.getAll().isEmpty)
        XCTAssertEqual(sut.getCount(), 5)
        let hero = try XCTUnwrap(sut.get(by: 0))
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
            case .ready, .logout, .sorted:
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
        XCTAssertNil(sut.get(by: 0))
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
            case .ready, .logout, .sorted:
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
        XCTAssertNil(sut.get(by: 0))
    }
    
    func testHome_WhenStateIsLogout() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let logoutExpectation = expectation(description: "Logout state succeed")
        let urlFile = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "jwt", withExtension: "txt"))
        let jwtData = try XCTUnwrap(Data(contentsOf: urlFile))
        mockLogoutUseCase.receivedData = jwtData
        
        // When
        sut.onStateChanged.bind { result in
            switch result {
            case .loading:
                loadingExpectation.fulfill()
            case .ready, .sorted, .error:
                XCTFail("Waiting for logout state")
            case .logout:
                logoutExpectation.fulfill()
            }
        }
        sut.logout()
        
        // Then
        wait(for: [loadingExpectation, logoutExpectation], timeout: 0.1)
    }
    
    func testHome_WhenStateIsSessionError() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let failureExpectation = expectation(description: "Logout state succeed")
        
        // When
        var receivedError: String?
        sut.onStateChanged.bind { result in
            switch result {
            case .loading:
                loadingExpectation.fulfill()
            case .ready, .sorted, .logout:
                XCTFail("Waiting for session error state")
            case let .error(errorMessage):
                receivedError = errorMessage
                failureExpectation.fulfill()
            }
        }
        sut.logout()
        
        // Then
        wait(for: [loadingExpectation, failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, "Session not found")
    }
}

import Foundation
import XCTest
@testable import DBIOSAdvanced

final class LogoutUseCaseTests: XCTestCase {
    var sut: LogoutUseCase!
    var mockSessionLocalDataSource: SessionLocalDataSourceProtocol!
    var mockStoreDataProvider: StoreDataProvider!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSessionLocalDataSource = MockSessionLocalDataSource()
        mockStoreDataProvider = StoreDataProvider(persistenceType: .memory)
        sut = LogoutUseCase(
            sessionLocalDataSource: mockSessionLocalDataSource,
            storeDataProvider: mockStoreDataProvider
        )
    }
    
    override func tearDownWithError() throws {
        mockSessionLocalDataSource.clear()
        mockSessionLocalDataSource = nil
        mockStoreDataProvider.clearBBDD()
        mockStoreDataProvider = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogout_WhenJWTIsNotEmpty_ShouldSucceed() throws {
        // Given
        let logoutExpectation = expectation(description: "Logout succeed")
        let urlFile = try XCTUnwrap(Bundle(for: LogoutUseCaseTests.self).url(forResource: "jwt", withExtension: "txt"))
        let jwtData = try XCTUnwrap(Data(contentsOf: urlFile))
        let herosDTO = HeroDTOData.givenList
        mockStoreDataProvider.insertHeros(herosDTO)
        mockSessionLocalDataSource.set(jwtData)
        
        // When
        let BBDDBefore = mockStoreDataProvider.fetchHeros()
        sut.run { result in
            switch result {
            case .success:
                logoutExpectation.fulfill()
            case .failure:
                XCTFail("Waiting for logout")
            }
        }
        let BBDDAfter = mockStoreDataProvider.fetchHeros()
        
        // Then
        wait(for: [logoutExpectation], timeout: 0.1)
        XCTAssertEqual(BBDDBefore.count, 5)
        XCTAssertEqual(BBDDAfter.count, 0)
        XCTAssertNil(mockSessionLocalDataSource.get())
    }
    
    func testLogout_WhenJWTIsEmpty_ShouldReturnError() throws {
        // Given
        let failureExpectation = expectation(description: "Logout failed")
        
        // When
        let BBDD = mockStoreDataProvider.fetchHeros()
        var receivedError: PresentationError?
        sut.run { result in
            switch result {
            case .success:
                XCTFail("Waiting for logout")
            case let .failure(error):
                receivedError = error
                failureExpectation.fulfill()
            }
        }
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNil(mockSessionLocalDataSource.get())
        XCTAssertEqual(BBDD.count, 0)
        XCTAssertEqual(receivedError, .session())
        XCTAssertEqual(receivedError?.reason, "Session not found")
    }
}

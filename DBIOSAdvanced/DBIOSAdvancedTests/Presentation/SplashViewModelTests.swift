import XCTest
@testable import DBIOSAdvanced

final class SplashViewModelTests: XCTestCase {
    var sut: SplashViewModel!
    var mockSessionLocalDataSource: MockSessionLocalDataSource!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSessionLocalDataSource = MockSessionLocalDataSource()
        sut = SplashViewModel(sessionLocalDataSource: mockSessionLocalDataSource)
    }
    
    override func tearDownWithError() throws {
        mockSessionLocalDataSource.clear()
        mockSessionLocalDataSource = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testSplash_WhenStateIsLogin() {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let loginExpectation = expectation(description: "Login state succeed")
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .login:
                loginExpectation.fulfill()
            case .home:
                XCTFail("Waiting for login")
            }
        }
        sut.load()
        
        // Then
        wait(for: [loadingExpectation, loginExpectation], timeout: 5)
    }
    
    func testSplash_WhenStateIsHome() throws {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let homeExpectation = expectation(description: "Home state succeed")
        let fileURL = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "jwt", withExtension: "txt"))
        let data = try XCTUnwrap(Data(contentsOf: fileURL))
        mockSessionLocalDataSource.set(data)
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .login:
                XCTFail("Waiting for home")
            case .home:
                homeExpectation.fulfill()
            }
        }
        sut.load()
        
        // Then
        wait(for: [loadingExpectation, homeExpectation], timeout: 5)
    }
}

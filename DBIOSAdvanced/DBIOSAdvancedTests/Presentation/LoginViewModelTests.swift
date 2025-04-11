import Foundation
import XCTest
@testable import DBIOSAdvanced

final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var mockLoginUseCase: MockLoginUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockLoginUseCase = MockLoginUseCase()
        sut = LoginViewModel(loginUseCase: mockLoginUseCase)
    }
    
    override func tearDownWithError() throws {
        mockLoginUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin_WhenStateIsReady() {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let readyExpectation = expectation(description: "Ready state succeed")
        mockLoginUseCase.receivedResponse = ()
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                readyExpectation.fulfill()
            case .fullScreenError(_):
                XCTFail("Waiting for ready state")
            case .inlineError(_):
                XCTFail("Waiting for ready state")
            }
        }
        sut.login(username: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        wait(for: [loadingExpectation, readyExpectation], timeout: 0.1)
    }
    
    func testLogin_WhenStateIsFullScreenError() {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let failureExpectation = expectation(description: "Full screen error state succeed")
        mockLoginUseCase.receivedResponse = ()
        mockLoginUseCase.receivedError = .network("Wrong email or password. Please log in again.")
        
        // When
        var receivedError: String?
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                XCTFail("Waiting for full screen error state")
            case let .fullScreenError(errorMessage):
                receivedError = errorMessage
                failureExpectation.fulfill()
            case .inlineError:
                XCTFail("Waiting for full screen error state")
            }
        }
        sut.login(username: "regularuser@keepcoding.es", password: "Regularuser1")
        
        // Then
        wait(for: [loadingExpectation, failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, "Wrong email or password. Please log in again.")
    }
    
    func testLogin_WhenStateIsInlineError() {
        // Given
        let loadingExpectation = expectation(description: "Loading state succeed")
        let failureExpectation = expectation(description: "Inline screen error state succeed")
        mockLoginUseCase.receivedResponse = ()
        mockLoginUseCase.receivedError = .regex(.email)
        
        // When
        var receivedError: RegexLintError?
        sut.onStateChanged.bind { state in
            switch state {
            case .loading:
                loadingExpectation.fulfill()
            case .ready:
                XCTFail("Waiting for inline error state")
            case .fullScreenError:
                XCTFail("Wrong email or password. Please log in again")
            case let .inlineError(regexLintError):
                receivedError = regexLintError
                failureExpectation.fulfill()
            }
        }
        sut.login(username: "regularuser", password: "Regularuser1")
        
        // Then
        wait(for: [loadingExpectation, failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError, .email)
        XCTAssertEqual(receivedError?.localizedDescription, "Email format is invalid")
    }
}

import Foundation
import XCTest
@testable import DBIOSAdvanced

final class LoginUseCaseTests: XCTestCase {
    var sut: LoginUseCaseProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let mockURLSession = URLSession(configuration: urlSessionConfiguration)
        let mockAPISession = APISession(urlSession: mockURLSession)
        let mockSessionLocalDataSource = MockSessionLocalDataSource()
        sut = LoginUseCase(
            apiSession: mockAPISession,
            sessionLocalDataSource: mockSessionLocalDataSource
        )
    }
    
    override func tearDownWithError() throws {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLogin_WhenCredentialsAreValid_ShouldSucceed() throws {
        // Given
        let successExpectation = expectation(description: "Login succeed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: LoginUseCaseTests.self).url(forResource: "jwt", withExtension: "txt"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        sut.run(username: "regularuser@keepcoding.es", password: "Regularuser1") { result in
            switch result {
            case .success:
                successExpectation.fulfill()
            case .failure:
                XCTFail("Waiting for success")
            }
        }
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedRequest)
        XCTAssertEqual(receivedRequest?.url?.path(), "/api/auth/login")
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(
            forHTTPHeaderField: "Authorization"), "Basic cmVndWxhcnVzZXJAa2VlcGNvZGluZy5lczpSZWd1bGFydXNlcjE="
        )
    }
    
    func testLogin_WhenCredentialsAreInvalid_ShouldReturnRegexError() {
        // Given
        let failureExpectation = expectation(description: "Login failed")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url))
            let fileURL = try XCTUnwrap(Bundle(for: LoginUseCaseTests.self).url(forResource: "jwt", withExtension: "txt"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedLoginError: PresentationError?
        sut.run(username: "regularuser", password: "Regularuser1") { result in
            switch result {
            case .success:
                XCTFail("Waiting for error")
            case .failure(let failure):
                receivedLoginError = failure
                failureExpectation.fulfill()
            }
        }
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedLoginError)
        XCTAssertEqual(receivedLoginError, .regex(.email))
    }
    
    func testLogin_WhenCredentialsAreWrong_ShouldRetunUnauthorizedError() {
        // Given
        let failureExpectation = expectation(description: "Failed ")
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 401))
            return (httpURLResponse, Data())
        }
        
        // When
        var receivedLoginError: PresentationError?
        sut.run(username: "regularuser@keepcoding.es", password: "12345678") { result in
            switch result {
            case .success:
                XCTFail("Waiting for failure")
            case .failure(let failure):
                receivedLoginError = failure
                failureExpectation.fulfill()
            }
        }
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNotNil(receivedLoginError)
        XCTAssertEqual(receivedLoginError?.reason, "Wrong email or password. Please log in again.")
    }
}

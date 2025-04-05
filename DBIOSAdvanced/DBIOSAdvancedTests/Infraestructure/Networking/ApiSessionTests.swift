import XCTest
@testable import DBIOSAdvanced

final class ApiSessionTests: XCTestCase {
    var sut: APISessionProtocol?

    override func setUpWithError() throws {
        try super.setUpWithError()
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: urlSessionConfiguration)
        sut = APISession(urlSession: urlSession)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoginHTTPRequest_ShouldReturnSuccess() throws {
        // Given
        let successExpectation = expectation(description: "Login succeed")
        var receivedRequest: URLRequest?
        MockURLProtocol.requestHandler = { request in
            receivedRequest = request
            let url = try XCTUnwrap(request.url)
            let httpURLResponse = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 200))
            let fileURL = try XCTUnwrap(Bundle(for: ApiSessionTests.self).url(forResource: "jwt", withExtension: "txt"))
            let data = try XCTUnwrap(Data(contentsOf: fileURL))
            return (httpURLResponse, data)
        }
        
        // When
        var receivedJWT: Data?
        let loginHTTPRequest = LoginHTTPRequest(
            username: "regularuser@keepcoding.es",
            password: "Regularuser1"
        )
        sut?.request(loginHTTPRequest, completion: { result in
            do {
                let jwt = try result.get()
                receivedJWT = jwt
                successExpectation.fulfill()
            } catch {
                XCTFail("Success expected")
            }
        })
        
        // Then
        wait(for: [successExpectation], timeout: 0.1)
        XCTAssertEqual(receivedRequest?.httpMethod, "POST")
        XCTAssertEqual(receivedRequest?.value(
            forHTTPHeaderField: "Authorization"), "Basic cmVndWxhcnVzZXJAa2VlcGNvZGluZy5lczpSZWd1bGFydXNlcjE="
        )
        XCTAssertNotNil(receivedJWT)
    }
    
    func testLoginHTTPRequest_ShouldReturnUnauthorizedError() throws {
        // Given
        let failureExpectation = expectation(description: "Login failed")
        failureExpectation.assertForOverFulfill = true
        MockURLProtocol.requestHandler = { request in
            let url = try XCTUnwrap(request.url)
            let request = try XCTUnwrap(MockURLProtocol.httpURLResponse(url: url, statusCode: 401))
            return (request, Data())
        }
        
        // When
        var receivedError: APIError?
        let loginHTTPRequest = LoginHTTPRequest(
            username: "user@keepcoding.es",
            password: "Regular"
        )
        sut?.request(loginHTTPRequest, completion: { result in
            do {
                let _ = try result.get()
                XCTFail("APIError expected")
            } catch let error as APIError {
                receivedError = error
                failureExpectation.fulfill()
            } catch {
                XCTFail("APIError expected")
            }
        })
        
        // Then
        wait(for: [failureExpectation], timeout: 0.1)
        let unauthorizedAPIError = try XCTUnwrap(receivedError)
        XCTAssertEqual(unauthorizedAPIError.url, "/api/auth/login")
        XCTAssertEqual(unauthorizedAPIError.reason, "Wrong email or password. Please log in again.")
        XCTAssertEqual(unauthorizedAPIError.statusCode, 401)
    }
}

import XCTest
@testable import DBIOSAdvanced

final class TransformationViewModelTests: XCTestCase {
    var sut: TransformationViewModel!
    var mockGetTransformationUseCase: MockGetTransformationUseCase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockGetTransformationUseCase = MockGetTransformationUseCase()
        sut = TransformationViewModel(
            identifier: "EE4DEC64-1B2D-47C1-A8EA-3208894A57A6",
            getTransformationUseCase: mockGetTransformationUseCase
        )
    }
    
    override func tearDownWithError() throws {
        mockGetTransformationUseCase = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoad_WhenStateIsReady() throws {
        // Given
        let readyExpectation = expectation(description: "Ready state succeed")
        let transformation = TransformationData.givenDomainList.filter {
            $0.identifier == "EE4DEC64-1B2D-47C1-A8EA-3208894A57A6"
        }.first
        mockGetTransformationUseCase.receivedResponse = transformation
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .ready:
                readyExpectation.fulfill()
            case .error:
                XCTFail("Waiting for ready state")
            }
        }
        sut.load()
        
        wait(for: [readyExpectation], timeout: 0.1)
        XCTAssertNotNil(sut.get())
        let transformationReceived = try XCTUnwrap(sut.get())
        XCTAssertEqual(transformationReceived.identifier, "EE4DEC64-1B2D-47C1-A8EA-3208894A57A6")
        XCTAssertEqual(transformationReceived.name, "3. Super Saiyan Blue")
    }
    
    func testLoad_WhenStateIsError() throws {
        // Given
        let failureExpectation = expectation(description: "Error state succeed")
        
        // When
        sut.onStateChanged.bind { state in
            switch state {
            case .ready:
                XCTFail("Waiting for error state")
            case .error:
                failureExpectation.fulfill()
            }
        }
        sut.load()
        
        wait(for: [failureExpectation], timeout: 0.1)
        XCTAssertNil(sut.get())
    }
}

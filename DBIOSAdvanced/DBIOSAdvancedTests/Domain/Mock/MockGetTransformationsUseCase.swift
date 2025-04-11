import XCTest
@testable import DBIOSAdvanced

final class MockGetTransformationsUseCase: GetTransformationsUseCaseProtocol {
    var receivedResponse: [Transformation]? = nil
    
    func run(heroIdentifer: String, completion: @escaping (Result<[Transformation], PresentationError>) -> Void) {
        guard let receivedResponse else {
            completion(.failure(.network("No data received")))
            return
        }
        
        if receivedResponse.isEmpty {
            completion(.failure(.emptyList()))
        } else {
            completion(.success(receivedResponse))
        }
    }
}

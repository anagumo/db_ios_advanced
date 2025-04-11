import XCTest
@testable import DBIOSAdvanced

final class MockGetTransformationUseCase: GetTransformationUseCaseProtocol {
    var receivedResponse: Transformation? = nil
    
    func run(identifer: String, completion: @escaping (Result<Transformation, PresentationError>) -> Void) {
        guard let receivedResponse else {
            completion(.failure(.notFound()))
            return
        }
        
        completion(.success(receivedResponse))
    }
}

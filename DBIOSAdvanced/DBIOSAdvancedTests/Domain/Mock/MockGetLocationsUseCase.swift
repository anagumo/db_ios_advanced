import XCTest
@testable import DBIOSAdvanced

final class MockGetLocationsUseCase: GetLocationsUseCaseProtocol {
    var receivedResponse: [Location]? = nil
    
    func run(heroIdentifer: String, completion: @escaping (Result<[Location], PresentationError>) -> Void) {
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

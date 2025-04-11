import XCTest
@testable import DBIOSAdvanced

final class MockHerosUseCase: GetHerosUseCaseProtocol {
    var receivedResponse: [Hero]? = nil
    
    func run(name: String, completion: @escaping (Result<[DBIOSAdvanced.Hero], DBIOSAdvanced.PresentationError>) -> Void) {
        guard let heroList = receivedResponse else {
            completion(.failure(.network("No data received")))
            return
        }
        
        if heroList.isEmpty {
            completion(.failure(.emptyList()))
        } else {
            completion(.success(heroList))
        }
    }
}

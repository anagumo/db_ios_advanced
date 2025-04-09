import Foundation
import XCTest
@testable import DBIOSAdvanced

final class MockLoginUseCase: LoginUseCaseProtocol {
    var receivedResponse: Void? = nil
    var receivedError: PresentationError? = nil
    
    func run(username: String, password: String, completion: @escaping (Result<Void, PresentationError>) -> Void) {
        guard let receivedResponse else {
            completion(.failure(.network("No data received")))
            return
        }
        
        if let receivedError {
            completion(.failure(receivedError))
        } else {
            completion(.success(receivedResponse))
        }
    }
}

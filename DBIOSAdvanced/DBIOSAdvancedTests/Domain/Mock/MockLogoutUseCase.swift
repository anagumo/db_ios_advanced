import XCTest
@testable import DBIOSAdvanced

final class MockLogoutUseCase: LogoutUseCaseProtocol {
    var receivedData: Data?
    
    func run(completion: @escaping (Result<Void, PresentationError>) -> Void) {
        guard  receivedData != nil else {
            completion(.failure(.session()))
            return
        }
        
        completion(.success(()))
    }
}

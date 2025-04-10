import Foundation
import OSLog

protocol LogoutUseCaseProtocol {
    func run(completion: @escaping (Result<Void, PresentationError>) -> Void)
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let sessionLocalDataSource: SessionLocalDataSourceProtocol
    
    init(sessionLocalDataSource: SessionLocalDataSourceProtocol = SessionLocalDataSource.shared) {
        self.sessionLocalDataSource = sessionLocalDataSource
    }
    
    func run(completion: @escaping (Result<Void, PresentationError>) -> Void) {
        guard sessionLocalDataSource.get() != nil else {
            Logger.log("JWT not found, unable to logout", level: .error, layer: .domain)
            completion(.failure(.session()))
            return
        }
        
        sessionLocalDataSource.clear()
        Logger.log("User session cleaned", level: .trace, layer: .domain)
        completion(.success(()))
    }
}

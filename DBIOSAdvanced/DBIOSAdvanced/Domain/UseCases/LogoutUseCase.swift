import Foundation
import OSLog

protocol LogoutUseCaseProtocol {
    func run(completion: @escaping (Result<Void, PresentationError>) -> Void)
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let sessionLocalDataSource: SessionLocalDataSourceProtocol
    private let storeDataProvider: StoreDataProvider
    
    init(
        sessionLocalDataSource: SessionLocalDataSourceProtocol = SessionLocalDataSource.shared,
        storeDataProvider: StoreDataProvider = .shared
    ) {
        self.sessionLocalDataSource = sessionLocalDataSource
        self.storeDataProvider = storeDataProvider
    }
    
    func run(completion: @escaping (Result<Void, PresentationError>) -> Void) {
        guard sessionLocalDataSource.get() != nil else {
            Logger.log("JWT not found, unable to logout", level: .error, layer: .domain)
            completion(.failure(.session()))
            return
        }
        
        sessionLocalDataSource.clear()
        storeDataProvider.clearBBDD()
        Logger.log("User session cleaned", level: .trace, layer: .domain)
        completion(.success(()))
    }
}

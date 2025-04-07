import Foundation
import OSLog

protocol GetHerosUseCaseProtocol {
    func run(name: String, completion: @escaping (Result<[Hero], HeroError>) -> Void)
}

final class GetHerosUseCase: GetHerosUseCaseProtocol {
    private let storeDataProvider: StoreDataProvider
    private let apiSession: APISessionProtocol
    
    init(storeDataProvider: StoreDataProvider, apiSession: APISessionProtocol) {
        self.storeDataProvider = storeDataProvider
        self.apiSession = apiSession
    }
    
    func run(name: String = "", completion: @escaping (Result<[Hero], HeroError>) -> Void) {
        let heroList = getFromLocal()
        
        if heroList.isEmpty {
            let getHerosHTTPRequest = GetHerosHTTPRequest(name: name)
            apiSession.request(getHerosHTTPRequest) { [weak self] result in
                do {
                    let heroDTOList = try result.get()
                    
                    guard !heroDTOList.isEmpty else {
                        Logger.log("Unexpected hero empty list", level: .info, layer: .domain)
                        completion(.failure(.emptyList()))
                        return
                    }
                    
                    // Is Swift concurrency allowed?
                    Task { @MainActor in
                        self?.storeDataProvider.insertHeros(heroDTOList)
                    }
                    
                    let heroList = heroDTOList.map { HeroDTOtoDomainMapper().map($0) }
                    Logger.log("Get heros succeed from remote", level: .info, layer: .domain)
                    completion(.success(heroList))
                } catch let error as APIError {
                    Logger.log("Get heros failed: \(error.reason)", level: .error, layer: .domain)
                    completion(.failure(.network(error.reason)))
                } catch {
                    Logger.log("Get heros uknown error: ", level: .error, layer: .domain)
                    completion(.failure(.uknown()))
                }
            }
        } else {
            Logger.log("Get heros succeed from local", level: .info, layer: .domain)
            completion(.success(heroList))
        }
    }
    
    private func getFromLocal() -> [Hero] {
        storeDataProvider
            .fetchHeros()
            .map { HeroEntityToDomainMapper().map($0) }
    }
}

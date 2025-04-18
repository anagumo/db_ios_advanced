import Foundation
import OSLog

protocol GetHerosUseCaseProtocol {
    func run(name: String, completion: @escaping (Result<[Hero], PresentationError>) -> Void)
}

final class GetHerosUseCase: GetHerosUseCaseProtocol {
    private let storeDataProvider: StoreDataProvider
    private let apiSession: APISessionProtocol
    
    init(
        storeDataProvider: StoreDataProvider = .shared,
        apiSession: APISessionProtocol = APISession.shared
    ) {
        self.storeDataProvider = storeDataProvider
        self.apiSession = apiSession
    }
    
    func run(name: String = "", completion: @escaping (Result<[Hero], PresentationError>) -> Void) {
        let heroList = getFromLocal(name)
        
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
                    
                    DispatchQueue.main.async {
                        self?.storeDataProvider.insertHeros(heroDTOList)
                        Logger.log("Get heros succeed from remote", level: .info, layer: .domain)
                        completion(.success(self?.getFromLocal(name) ?? []))
                    }
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
    
    private func getFromLocal(_ name: String) -> [Hero] {
        if name.isEmpty {
            return storeDataProvider
                .fetchHeros()
                .map { HeroEntityToDomainMapper().map($0) }
        } else {
            guard let heroEntity = storeDataProvider.fetchHero(name: name) else {
                return []
            }
            
            return [HeroEntityToDomainMapper().map(heroEntity)]
        }
    }
}

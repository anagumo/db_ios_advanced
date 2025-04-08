import Foundation
import OSLog

protocol GetLocationsUseCaseProtocol {
    func run(heroIdentifer: String, completion: @escaping (Result<[Location], PresentationError>) -> Void)
}

final class GetLocationsUseCase: GetLocationsUseCaseProtocol {
    private let storeDataProvider: StoreDataProvider
    private let apiSession: APISessionProtocol
    
    init(storeDataProvider: StoreDataProvider, apiSession: APISessionProtocol) {
        self.storeDataProvider = storeDataProvider
        self.apiSession = apiSession
    }
    
    func run(heroIdentifer: String, completion: @escaping (Result<[Location], PresentationError>) -> Void) {
        let locationList = getFromLocal(heroIdentifer)
        
        if locationList.isEmpty {
            let getLocationHTTPRequest = GetLocationsHTTPRequest(heroIdentifier: heroIdentifer)
            apiSession.request(getLocationHTTPRequest) { [weak self] result in
                do {
                    let locationDTOList = try result.get()
                    
                    guard !locationDTOList.isEmpty else {
                        Logger.log("Unexpected locations empty list", level: .info, layer: .domain)
                        completion(.failure(.emptyList()))
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.storeDataProvider.insertLocations(locationDTOList)
                        Logger.log("Get locations succeed from remote", level: .info, layer: .domain)
                        completion(.success(self?.getFromLocal(heroIdentifer) ?? []))
                    }
                    
                } catch let error as APIError {
                    Logger.log("Get locations failed: \(error.reason)", level: .error, layer: .domain)
                    completion(.failure(.network(error.reason)))
                } catch {
                    Logger.log("Get locations uknown error: ", level: .error, layer: .domain)
                    completion(.failure(.uknown()))
                }
            }
        } else {
            Logger.log("Get locations succeed from local", level: .info, layer: .domain)
            completion(.success(locationList))
        }
    }
    
    func getFromLocal(_ heroIdentifer: String) -> [Location] {
        storeDataProvider.fetchLocations(heroIdentifier: heroIdentifer)
            .compactMap { LocationEntityToDomainMapper().map($0) }
    }
}


import Foundation
import OSLog

protocol GetTransformationsUseCaseProtocol {
    func run(heroIdentifer: String, completion: @escaping (Result<[Transformation], AppError>) -> Void)
}

final class TransformationsUseCase: GetTransformationsUseCaseProtocol {
    private let storeDataProvider: StoreDataProvider
    private let apiSession: APISessionProtocol
    
    init(storeDataProvider: StoreDataProvider, apiSession: APISessionProtocol) {
        self.storeDataProvider = storeDataProvider
        self.apiSession = apiSession
    }
    
    func run(heroIdentifer: String, completion: @escaping (Result<[Transformation], AppError>) -> Void) {
        let transformationList = getFromLocal(heroIdentifer)
        
        if transformationList.isEmpty {
            let getTransformationsHTTPRequest = GetTransformationsHTTPRequest(heroIdentifier: heroIdentifer)
            apiSession.request(getTransformationsHTTPRequest) { [weak self] result in
                do {
                    let transformationDTOList = try result.get()
                    
                    guard !transformationDTOList.isEmpty else {
                        Logger.log("Unexpected transformation empty list", level: .info, layer: .domain)
                        completion(.failure(.emptyList()))
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.storeDataProvider.insertTransformations(transformationDTOList)
                        Logger.log("Get transformations succeed from remote", level: .info, layer: .domain)
                        completion(.success(self?.getFromLocal(heroIdentifer) ?? []))
                    }
                    
                } catch let error as APIError {
                    Logger.log("Get transformations failed: \(error.reason)", level: .error, layer: .domain)
                    completion(.failure(.network(error.reason)))
                } catch {
                    Logger.log("Get transformations uknown error: ", level: .error, layer: .domain)
                    completion(.failure(.uknown()))
                }
            }
        } else {
            Logger.log("Get transformations succeed from local", level: .info, layer: .domain)
            completion(.success(transformationList))
        }
    }
    
    func getFromLocal(_ heroIdentifer: String) -> [Transformation] {
        storeDataProvider.fetchTransformations(heroIdentifier: heroIdentifer).compactMap {
            TransformationEntityToDomainMapper().map($0)
        }
    }
}

import Foundation
import OSLog

protocol GetTransformationUseCaseProtocol {
    func run(identifer: String, completion: @escaping (Result<Transformation, AppError>) -> Void)
}

final class GetTransformationUseCase: GetTransformationUseCaseProtocol {
    private let storeDataProvider: StoreDataProvider
    
    init(storeDataProvider: StoreDataProvider) {
        self.storeDataProvider = storeDataProvider
    }
    
    func run(identifer: String, completion: @escaping (Result<Transformation, AppError>) -> Void) {
        let transformation = getFromLocal(identifer)
        
        if let transformation {
            Logger.log("Get transformation succeed from local", level: .info, layer: .domain)
            completion(.success(transformation))
        } else {
            Logger.log("Get transformation failed from local", level: .error, layer: .domain)
            completion(.failure(.notFound()))
        }
    }
    
    func getFromLocal(_ identifer: String) -> Transformation? {
        guard let transformationEntity = storeDataProvider.fetchTransformation(identifier: identifer) else {
            return nil
        }
        return TransformationEntityToDomainMapper().map(transformationEntity)
    }
}

import Foundation
import OSLog

protocol SortHerosUseCaseProtocol {
    func run(sortAscending: Bool, completion: @escaping (Result<[Hero], PresentationError>) -> Void)
}

final class SortHerosUseCase: SortHerosUseCaseProtocol {
    private let storeDataProvider: StoreDataProvider
    
    init(storeDataProvider: StoreDataProvider = .shared) {
        self.storeDataProvider = storeDataProvider
    }
    
    func run(sortAscending: Bool = true, completion: @escaping (Result<[Hero], PresentationError>) -> Void) {
        let sortedHeroList = storeDataProvider
            .fetchHeros(sortAscending: sortAscending)
            .map { HeroEntityToDomainMapper().map($0) }
        
        guard !sortedHeroList.isEmpty else {
            completion(.failure(.emptyList()))
            return
        }
        completion(.success(sortedHeroList))
    }
}

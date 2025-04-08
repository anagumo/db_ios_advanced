import Foundation
import OSLog

/// Represents a state on the screen
enum HerosState: Equatable {
    case loading
    case ready
    case error(String)
}

protocol HerosViewModelProtocol {
    func load()
    func getAll() -> [Hero]
    func getCount() -> Int
    func getHero(position: Int) -> Hero
}

final class HerosViewModel: HerosViewModelProtocol {
    private let name: String
    private let herosUseCase: GetHerosUseCaseProtocol
    private(set) var heroList: [Hero]
    var onStateChanged = Binding<HerosState>()
    
    init(name: String, herosUseCase: GetHerosUseCaseProtocol) {
        self.name = name
        self.herosUseCase = herosUseCase
        self.heroList = []
    }
    
    func load() {
        herosUseCase.run(name: name) { [weak self] result in
            do {
                let heroList = try result.get()
                self?.heroList = heroList
                self?.onStateChanged.update(.ready)
            } catch let error as PresentationError {
                self?.onStateChanged.update(.error(error.reason))
            } catch {
                self?.onStateChanged.update(.error(error.localizedDescription))
            }
        }
    }
    
    func getAll() -> [Hero] {
        heroList
    }
    
    func getCount() -> Int {
        heroList.count
    }
    
    func getHero(position: Int) -> Hero {
        heroList[position]
    }
}

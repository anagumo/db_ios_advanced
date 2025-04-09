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
    func getHero(position: Int) -> Hero?
}

final class HerosViewModel: HerosViewModelProtocol {
    private let herosUseCase: GetHerosUseCaseProtocol
    private var heroList: [Hero]
    var onStateChanged = Binding<HerosState>()
    
    init(herosUseCase: GetHerosUseCaseProtocol) {
        self.herosUseCase = herosUseCase
        self.heroList = []
    }
    
    func load() {
        onStateChanged.update(.loading)
        
        herosUseCase.run(name: "") { [weak self] result in
            do {
                let heroList = try result.get()
                self?.heroList = heroList
                Logger.log("Heros state updated to ready", level: .info, layer: .presentation)
                self?.onStateChanged.update(.ready)
            } catch let error as PresentationError {
                Logger.log("Heros state updated to error: \(error.reason)", level: .error, layer: .presentation)
                self?.onStateChanged.update(.error(error.reason))
            } catch {
                Logger.log("Heros state updated to error", level: .error, layer: .presentation)
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
    
    func getHero(position: Int) -> Hero? {
        guard position < heroList.count else {
            Logger.log("Hero not found in the list", level: .error, layer: .presentation)
            return nil
        }
        return heroList[position]
    }
}

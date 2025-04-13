import Foundation
import OSLog

/// Represents a state on the screen
enum HerosState: Equatable {
    case loading
    case ready
    case sorted
    case logout
    case error(String)
}

protocol HerosViewModelProtocol {
    var onStateChanged: Binding<HerosState> { get }
    func load()
    func getAll() -> [Hero]
    func getCount() -> Int
    func get(by position: Int) -> Hero?
    func filter(by inputText: String) -> [Hero]
    func sort()
    func logout()
}

final class HerosViewModel: HerosViewModelProtocol {
    private let herosUseCase: GetHerosUseCaseProtocol
    private let sortHerosUseCase: SortHerosUseCase
    private let logoutUseCase: LogoutUseCaseProtocol
    private var heroList: [Hero]
    private var heroListFiltered: [Hero]
    private var sortAscending: Bool
    private(set) var onStateChanged = Binding<HerosState>()
    
    init(herosUseCase: GetHerosUseCaseProtocol,
         sortHerosUseCase: SortHerosUseCase,
         logoutUseCase: LogoutUseCaseProtocol) {
        self.herosUseCase = herosUseCase
        self.sortHerosUseCase = sortHerosUseCase
        self.logoutUseCase = logoutUseCase
        self.heroList = []
        self.heroListFiltered = []
        self.sortAscending = true
    }
    
    func load() {
        onStateChanged.update(.loading)
        
        herosUseCase.run(name: "") { [weak self] result in
            switch result {
            case let.success(heroList):
                self?.heroList = heroList
                Logger.log("Heros state updated to ready", level: .info, layer: .presentation)
                self?.onStateChanged.update(.ready)
            case let .failure(error):
                Logger.log("Heros state updated to heros error: \(error.reason)", level: .error, layer: .presentation)
                self?.onStateChanged.update(.error(error.reason))
            }
        }
    }
    
    func getAll() -> [Hero] {
        heroList
    }
    
    func getCount() -> Int {
        heroList.count
    }
    
    func get(by position: Int) -> Hero? {
        guard position < heroList.count else {
            Logger.log("Hero not found in the list", level: .error, layer: .presentation)
            return nil
        }
        return heroList[position]
    }
    
    func filter(by inputText: String) -> [Hero] {
        heroList.filter {
            $0.name?
                .lowercased()
                .contains(inputText.lowercased()) ?? false
        }
    }
    
    func sort() {
        sortAscending.toggle()
        sortHerosUseCase.run(sortAscending: sortAscending) { [weak self] result in
            switch result {
            case let.success(heroList):
                self?.heroList = heroList
                Logger.log("Heros state updated to sorted", level: .info, layer: .presentation)
                self?.onStateChanged.update(.sorted)
            case let .failure(error):
                Logger.log("Heros state updated to sorted heros error: \(error.reason)", level: .error, layer: .presentation)
                self?.onStateChanged.update(.error(error.reason))
            }
        }
    }
    
    func logout() {
        onStateChanged.update(.loading)
        
        logoutUseCase.run { [weak self] result in
            switch result {
            case .success:
                Logger.log("Home state updated to logout", level: .trace, layer: .presentation)
                self?.onStateChanged.update(.logout)
            case .failure(let error):
                Logger.log("Home state updated to logout error", level: .error, layer: .presentation)
                self?.onStateChanged.update(.error(error.reason))
            }
        }
    }
}

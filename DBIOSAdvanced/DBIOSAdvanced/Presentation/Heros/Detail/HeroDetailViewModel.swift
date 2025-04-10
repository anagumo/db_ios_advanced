import Foundation

enum HeroState: Equatable {
    case ready
    case error(String)
}

protocol HeroDetailViewModelProtocol {
    var onStateChanged: Binding<HeroState> { get }
    func load()
}

final class HeroDetailViewModel: HeroDetailViewModelProtocol {
    private let getHeroUseCase: GetHerosUseCase
    private let name: String
    var onStateChanged: Binding<HeroState>
    var hero: Hero?
    
    init(name: String, getHeroUseCase: GetHerosUseCase) {
        self.name = name
        self.getHeroUseCase = getHeroUseCase
        self.onStateChanged = Binding<HeroState>()
    }
    
    func load() {
        getHeroUseCase.run(name: name) { [weak self] result in
            switch result {
            case .success(let heros):
                guard let hero = heros.first else {
                    self?.onStateChanged.update(.error(PresentationError.notFound().reason))
                    return
                }
                self?.hero = hero
                self?.onStateChanged.update(.ready)
            case .failure(let error):
                self?.onStateChanged.update(.error(error.reason))
            }
        }
    }
}

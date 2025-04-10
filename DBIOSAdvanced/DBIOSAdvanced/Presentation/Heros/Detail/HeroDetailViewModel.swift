import Foundation
import MapKit
import OSLog

enum HeroState: Equatable {
    case ready
    case locations
    case transformations
    case error(String)
}

protocol HeroDetailViewModelProtocol {
    var onStateChanged: Binding<HeroState> { get }
    func load()
    func loadLocations()
    func loadTransformations()
    func get() -> Hero?
    func getMapAnnotations() -> [HeroAnnotation]
    func getMapRegion() -> MKCoordinateRegion?
}

final class HeroDetailViewModel: HeroDetailViewModelProtocol {
    private let getHeroUseCase: GetHerosUseCaseProtocol
    private let getLocationsUseCase: GetLocationsUseCaseProtocol
    private let getTransformationsUseCase: GetTransformationsUseCaseProtocol
    private let name: String
    var onStateChanged: Binding<HeroState>
    var hero: Hero?
    var locations: [Location]
    var transformations: [Transformation]
    
    init(
        name: String,
        getHeroUseCase: GetHerosUseCaseProtocol,
        getLocationsUseCase: GetLocationsUseCaseProtocol,
        getTransformationsUseCase: GetTransformationsUseCaseProtocol
    ) {
        self.name = name
        self.getHeroUseCase = getHeroUseCase
        self.getLocationsUseCase = getLocationsUseCase
        self.getTransformationsUseCase = getTransformationsUseCase
        self.onStateChanged = Binding<HeroState>()
        locations = []
        transformations = []
    }
    
    func load() {
        getHeroUseCase.run(name: name) { [weak self] result in
            switch result {
            case let .success(heros):
                guard let hero = heros.first else {
                    self?.onStateChanged.update(.error(PresentationError.notFound().reason))
                    return
                }
                self?.hero = hero
                self?.onStateChanged.update(.ready)
            case let .failure(error):
                self?.onStateChanged.update(.error(error.reason))
            }
        }
    }
    
    func loadLocations() {
        guard let heroIdentifier = hero?.identifier else { return }
        
        getLocationsUseCase.run(heroIdentifer: heroIdentifier, completion: { [weak self] result in
            switch result {
            case let .success(locations):
                self?.locations = locations
                self?.onStateChanged.update(.locations)
            case let .failure(error):
                Logger.log(error.reason, level: .error, layer: .presentation)
            }
        })
    }
    
    func loadTransformations() {
        guard let heroIdentifier = hero?.identifier else { return }
        
        getTransformationsUseCase.run(heroIdentifer: heroIdentifier, completion: { [weak self] result in
            switch result {
            case let .success(transformations):
                self?.transformations = transformations
                self?.onStateChanged.update(.transformations)
            case let .failure(error):
                Logger.log(error.reason, level: .error, layer: .presentation)
            }
        })
    }
    
    func get() -> Hero? {
        hero
    }
    
    func getMapAnnotations() -> [HeroAnnotation] {
        locations.compactMap {
            $0.annotation
        }
    }
    
    func getMapRegion() -> MKCoordinateRegion? {
        guard let region = locations.first?.region else {
            return nil
        }
        
        return region
    }
}

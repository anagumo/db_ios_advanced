import Foundation
import MapKit
import OSLog

enum HeroState: Equatable {
    case ready
    case locations
    case transformations
    case error(String)
}

protocol HeroViewModelProtocol {
    var onStateChanged: Binding<HeroState> { get }
    func load()
    func loadLocations()
    func loadTransformations()
    func get() -> Hero?
    func getMapAnnotations() -> [HeroAnnotation]
    func getMapRegion() -> MKCoordinateRegion?
    func getTransformations() -> [Transformation]
    func getTransformation(_ position: Int) -> Transformation?
}

final class HeroViewModel: HeroViewModelProtocol {
    private let getHerosUseCase: GetHerosUseCaseProtocol
    private let getLocationsUseCase: GetLocationsUseCaseProtocol
    private let getTransformationsUseCase: GetTransformationsUseCaseProtocol
    private let name: String
    var onStateChanged: Binding<HeroState>
    var hero: Hero?
    var locationList: [Location]
    var transformationList: [Transformation]
    
    init(
        name: String,
        getHerosUseCase: GetHerosUseCaseProtocol,
        getLocationsUseCase: GetLocationsUseCaseProtocol,
        getTransformationsUseCase: GetTransformationsUseCaseProtocol
    ) {
        self.name = name
        self.getHerosUseCase = getHerosUseCase
        self.getLocationsUseCase = getLocationsUseCase
        self.getTransformationsUseCase = getTransformationsUseCase
        self.onStateChanged = Binding<HeroState>()
        locationList = []
        transformationList = []
    }
    
    func load() {
        getHerosUseCase.run(name: name) { [weak self] result in
            switch result {
            case let .success(heroList):
                guard let hero = heroList.first else {
                    Logger.log(PresentationError.notFound().reason, level: .critical, layer: .presentation)
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
        guard let heroIdentifier = hero?.identifier else {
            Logger.log(PresentationError.notFound().reason, level: .critical, layer: .presentation)
            return
        }
        
        getLocationsUseCase.run(heroIdentifer: heroIdentifier, completion: { [weak self] result in
            switch result {
            case let .success(locations):
                self?.locationList = locations
                self?.onStateChanged.update(.locations)
            case let .failure(error):
                Logger.log(error.reason, level: .error, layer: .presentation)
            }
        })
    }
    
    func loadTransformations() {
        guard let heroIdentifier = hero?.identifier else {
            Logger.log(PresentationError.notFound().reason, level: .critical, layer: .presentation)
            return
        }
        
        getTransformationsUseCase.run(heroIdentifer: heroIdentifier, completion: { [weak self] result in
            switch result {
            case let .success(transformations):
                self?.transformationList = transformations
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
        locationList.compactMap {
            $0.annotation
        }
    }
    
    func getMapRegion() -> MKCoordinateRegion? {
        guard let region = locationList.first?.region else {
            return nil
        }
        
        return region
    }
    
    func getTransformations() -> [Transformation] {
        transformationList
    }
    
    func getTransformation(_ position: Int) -> Transformation? {
        guard position < transformationList.count else {
            Logger.log("Transformation not found in the list", level: .error, layer: .presentation)
            return nil
        }
        return transformationList[position]
    }
}

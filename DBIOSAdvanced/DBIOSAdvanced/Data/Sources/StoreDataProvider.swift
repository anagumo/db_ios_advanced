import Foundation
import SwiftData
import OSLog

protocol StoreDataProviderProtocol {
    func fetchHeros(name: String?, sortAscending: Bool) -> [HeroEntity]
    func fetchTransformations(heroName: String) -> [TransformationEntity]
    func fetchLocations(heroName: String) -> [LocationEntity]
    func clearBBDD()
}

final class StoreDataProvider: StoreDataProviderProtocol {
    static let shared = StoreDataProvider()
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = true
        return ModelContext(modelContainer)
    }()
    
    init() {
        let urlBBDD = URL.applicationSupportDirectory.appending(component: "DragonBall.sqlite")
        let modelConfiguration = ModelConfiguration(url: urlBBDD)
        do {
            modelContainer = try ModelContainer(
                for: HeroEntity.self, TransformationEntity.self, LocationEntity.self,
                configurations: modelConfiguration
            )
        } catch {
            Logger.log("Swift Data couln not load BBDD", level: .critical, layer: .repository)
            fatalError("Swift Data could not load BBDD: \(error)")
        }
    }
    
    func saveContext() {
        guard modelContext.hasChanges else {
            Logger.log("There is no changes to apply in BBDD", level: .warning, layer: .repository)
            return
        }
        
        do {
            try modelContext.save()
        } catch {
            Logger.log("Unexpected error saving BBDD context: \(error)", level: .error, layer: .repository)
        }
    }
    
    func fetchHeros(name: String? = nil, sortAscending: Bool = false) -> [HeroEntity] {
        var fetchDescriptor = FetchDescriptor<HeroEntity>()
        if let name {
            fetchDescriptor.predicate = #Predicate { $0.name == name }
        }
        let sortDescriptor = SortDescriptor<HeroEntity>(\.name, order: sortAscending ? .forward : .reverse)
        fetchDescriptor.sortBy = [sortDescriptor]
        
        do {
            let heroEntities = try modelContext.fetch(fetchDescriptor)
            return heroEntities
        } catch {
            Logger.log("Hero entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
    }
    
    func fetchTransformations(heroName: String) -> [TransformationEntity] {
        guard let hero = fetchHeros(name: heroName).first else {
            Logger.log("Hero entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
        
        return hero.transformations ?? []
    }
    
    func fetchLocations(heroName: String) -> [LocationEntity] {
        guard let hero = fetchHeros(name: heroName).first else {
            Logger.log("Hero entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
        return hero.locations ?? []
    }
    
    func clearBBDD() {
        modelContext.rollback()
        
        do {
            try modelContext.delete(model: HeroEntity.self)
            try modelContext.delete(model: TransformationEntity.self)
            try modelContext.delete(model: LocationEntity.self)
        } catch {
            Logger.log("Unexpected error clearing BBDD", level: .error, layer: .repository)
        }
    }
}

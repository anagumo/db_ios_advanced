import Foundation
import SwiftData
import OSLog

protocol StoreDataProviderProtocol {
    func fetchHeros(predicate: Predicate<HeroEntity>, sortDescriptor: SortDescriptor<HeroEntity>) -> [HeroEntity]
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
    
    func fetchHeros(predicate: Predicate<HeroEntity>, sortDescriptor: SortDescriptor<HeroEntity>) -> [HeroEntity] {
        let fetchDescriptor = FetchDescriptor<HeroEntity>(predicate: predicate, sortBy: [sortDescriptor])
        do {
            let heroEntities = try modelContext.fetch(fetchDescriptor)
            return heroEntities
        } catch {
            Logger.log("Hero Entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
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

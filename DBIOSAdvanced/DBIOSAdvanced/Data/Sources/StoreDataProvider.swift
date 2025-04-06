import Foundation
import SwiftData
import OSLog

enum PersistenceType: String {
    case memory
    case disk
}

final class StoreDataProvider {
    static let shared = StoreDataProvider()
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = true
        return ModelContext(modelContainer)
    }()
    
    init(persistenceType: PersistenceType = .disk) {
        let modelConfiguration: ModelConfiguration?
        if persistenceType == .disk {
            let urlBBDD = URL.applicationSupportDirectory.appending(component: "DragonBall.sqlite")
            modelConfiguration = ModelConfiguration(url: urlBBDD)
        } else {
            modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        }
        
        do {
            if let modelConfiguration {
                modelContainer = try ModelContainer(
                    for: HeroEntity.self, TransformationEntity.self, LocationEntity.self,
                    configurations: modelConfiguration
                )
            } else {
                Logger.log("Unexpected error creating the model container", level: .warning, layer: .repository)
                throw SwiftDataError.loadIssueModelContainer
            }
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
    
    func insertHeros(_ heroDTOList: [HeroDTO]) {
        heroDTOList.forEach {
            modelContext.insert(HeroDTOtoEntityMapper().map($0))
        }
        
        saveContext()
    }
    
    func insertTransformations(_ transformationsDTOList: [TransformationDTO]) {
        transformationsDTOList.forEach {
            let heroEntity = fetchHero(identifier: $0.hero?.identifier)
            modelContext.insert(
                TransformationDTOtoEntityMapper().map($0, relationship: heroEntity)
            )
        }
        
        saveContext()
    }
    
    func insertLocations(_ locationsDTOList: [LocationDTO]) {
        locationsDTOList.forEach {
            let heroEntity = fetchHero(identifier: $0.hero?.identifier)
            modelContext.insert(
                LocationDTOtoEntityMapper().map($0, relationship: heroEntity)
            )
        }
        
        saveContext()
    }
    
    func fetchHeros(sortAscending: Bool = true) -> [HeroEntity] {
        var fetchDescriptor = FetchDescriptor<HeroEntity>()
        let sortDescriptor = SortDescriptor<HeroEntity>(\.name, order: sortAscending ? .forward : .reverse)
        fetchDescriptor.sortBy = [sortDescriptor]
        
        do {
            let heroEntityList = try modelContext.fetch(fetchDescriptor)
            return heroEntityList
        } catch {
            Logger.log("Hero entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
    }
    
    func fetchHero(identifier: String? = nil, name: String? = nil) -> HeroEntity? {
        var fetchDescriptor = FetchDescriptor<HeroEntity>()
        
        if let identifier {
            fetchDescriptor.predicate = #Predicate { $0.identifier == identifier }
        }
        
        if let name {
            fetchDescriptor.predicate = #Predicate { $0.name == name }
        }
        
        do {
            let heroEntity = try modelContext.fetch(fetchDescriptor).first
            return heroEntity
        } catch {
            Logger.log("Hero entity not found in BBDD", level: .error, layer: .repository)
            return nil
        }
    }
    
    func fetchTransformations(heroIdentifier: String) -> [TransformationEntity] {
        var fetchDescriptor = FetchDescriptor<TransformationEntity>()
        fetchDescriptor.predicate = #Predicate { $0.hero?.identifier == heroIdentifier }
        let sortDescriptor = SortDescriptor<TransformationEntity>(\.name, order: .forward)
        fetchDescriptor.sortBy = [sortDescriptor]
        
        do {
            let transformationEntityList = try modelContext.fetch(fetchDescriptor)
            return transformationEntityList
        } catch {
            Logger.log("Transformation entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
    }
    
    func fetchTransformation(identifier: String) -> TransformationEntity? {
        var fetchDescriptor = FetchDescriptor<TransformationEntity>()
        fetchDescriptor.predicate = #Predicate { $0.identifier == identifier }
        
        do {
            let transformationEntity = try modelContext.fetch(fetchDescriptor).first
            return transformationEntity
        } catch {
            Logger.log("Transformation entity not found in BBDD", level: .error, layer: .repository)
            return nil
        }
    }
    
    func fetchLocations(heroIdentifier: String) -> [LocationEntity] {
        guard let heroEntity = fetchHero(identifier: heroIdentifier) else {
            Logger.log("Hero entity not found in BBDD", level: .error, layer: .repository)
            return []
        }
        return heroEntity.locations ?? []
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

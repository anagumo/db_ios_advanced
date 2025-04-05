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
            let heroEntity = fetchHeros(identifier: $0.hero?.identifier).first
            modelContext.insert(
                TransformationDTOtoEntityMapper().map($0, relationship: heroEntity)
            )
        }
        
        saveContext()
    }
    
    func insertLocations(_ locationsDTOList: [LocationDTO]) {
        locationsDTOList.forEach {
            let heroEntity = fetchHeros(identifier: $0.hero?.identifier).first
            modelContext.insert(
                LocationDTOtoEntityMapper().map($0, relationship: heroEntity)
            )
        }
        
        saveContext()
    }
    
    func fetchHeros(identifier: String? = nil, name: String? = nil, sortAscending: Bool = true) -> [HeroEntity] {
        var fetchDescriptor = FetchDescriptor<HeroEntity>()
        
        if let identifier {
            fetchDescriptor.predicate = #Predicate { $0.identifier == identifier }
        }
        
        if let name {
            fetchDescriptor.predicate = #Predicate { $0.name == name }
        }
        
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
    
    func fetchTransformations(heroID: String) -> [TransformationEntity] {
        guard let heroEntity = fetchHeros(identifier: heroID).first else {
            Logger.log("Hero entities not found in BBDD", level: .error, layer: .repository)
            return []
        }
        
        return heroEntity.transformations ?? []
    }
    
    func fetchLocations(heroID: String) -> [LocationEntity] {
        guard let heroEntity = fetchHeros(identifier: heroID).first else {
            Logger.log("Hero entities not found in BBDD", level: .error, layer: .repository)
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

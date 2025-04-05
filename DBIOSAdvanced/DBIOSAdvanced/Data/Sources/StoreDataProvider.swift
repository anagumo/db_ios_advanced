import Foundation
import SwiftData
import OSLog

final class StoreDataProvider {
    static let shared = StoreDataProvider()
    private let modelContainer: ModelContainer
    private lazy var modelContext: ModelContext = {
        let context = ModelContext(modelContainer)
        context.autosaveEnabled = true
        return ModelContext(modelContainer)
    }()
    
    init() {
        let urlBBDD = URL.applicationSupportDirectory.appending(component: "DragonBall.sqlite")
        var modelConfiguration = ModelConfiguration(url: urlBBDD)
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
}

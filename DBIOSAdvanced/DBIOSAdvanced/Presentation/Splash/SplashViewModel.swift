import Foundation
import OSLog

/// Represent the screen states
enum SplashState: Equatable {
    case loading
    case login
    case home
}

protocol SplashViewModelProtocol {
    func load()
}

final class SplashViewModel: SplashViewModelProtocol {
    private let sessionLocalDataSource: SessionLocalDataSourceProtocol
    let onStateChanged = Binding<SplashState>()
    
    init(sessionLocalDataSource: SessionLocalDataSourceProtocol) {
        self.sessionLocalDataSource = sessionLocalDataSource
    }
    
    func load() {
        onStateChanged.update(.loading)
        
        // Execute this code on a secondary thread, to send data to UI layer is necessary change to the main thread
        // The Binding generic class makes the switch from Global queue -> Main thread
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.sessionLocalDataSource.get() == nil {
                Logger.log("Splash state updated to login", level: .trace, layer: .presentation)
                self?.onStateChanged.update(.login)
            } else {
                Logger.log("Splash state updated to home", level: .trace, layer: .presentation)
                self?.onStateChanged.update(.home)
            }
        }
    }
}

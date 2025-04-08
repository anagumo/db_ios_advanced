import Foundation

/// Represent the screen states
enum SplashState: Equatable {
    case loading
    case login
    case logged
}

protocol SplashViewModelProtocol {
    func load()
}

final class SplashViewModel: SplashViewModelProtocol {
    let onStateChanged = Binding<SplashState>()
    private let sessionLocalDataSource: SessionLocalDataSource
    
    init(sessionLocalDataSource: SessionLocalDataSource) {
        self.sessionLocalDataSource = sessionLocalDataSource
    }
    
    func load() {
        onStateChanged.update(.loading)
        
        // Execute this code on a secondary thread, to send data to UI layer is necessary change to the main thread
        // The Binding generic class makes the switch from Global queue -> Main thread
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            if self?.sessionLocalDataSource.get() == nil {
                self?.onStateChanged.update(.login)
            } else {
                self?.onStateChanged.update(.logged)
            }
        }
    }
}

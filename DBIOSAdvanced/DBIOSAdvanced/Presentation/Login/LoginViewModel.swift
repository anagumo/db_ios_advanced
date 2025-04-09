import Foundation
import OSLog

/// Represents a state on the screen
enum LoginState: Equatable {
    case loading
    case ready
    case fullScreenError(String) // For blocking errors
    case inlineError(RegexLintError) // For errors on ui ej. below text fields
}

protocol LoginViewModelProtocol {
    func login(username: String, password: String)
}

final class LoginViewModel: LoginViewModelProtocol {
    private let loginUseCase: LoginUseCaseProtocol
    var onStateChanged: Binding<LoginState>
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        self.onStateChanged = Binding<LoginState>()
    }
    
    func login(username: String, password: String) {
        onStateChanged.update(.loading)
        
        loginUseCase.run(username: username, password: password) { [weak self] result in
            switch result {
            case .success:
                Logger.log("Login state updated to ready", level: .trace, layer: .presentation)
                self?.onStateChanged.update(.ready)
            case let .failure(failure):
                guard let regexLintError = failure.regex else {
                    Logger.log("Login state updated to full screen error", level: .trace, layer: .presentation)
                    self?.onStateChanged.update(.fullScreenError(failure.reason))
                    return
                }
                Logger.log("Login state updated to inline error", level: .trace, layer: .presentation)
                self?.onStateChanged.update(.inlineError(regexLintError))
            }
        }
    }
}

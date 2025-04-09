import Foundation

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
    private let loginUseCase: LoginUseCase
    var onStateChanged: Binding<LoginState>
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
        self.onStateChanged = Binding<LoginState>()
    }
    
    func login(username: String, password: String) {
        onStateChanged.update(.loading)
        
        loginUseCase.run(username: username, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.onStateChanged.update(.ready)
            case let .failure(failure):
                guard let regexLintError = failure.regex else {
                    self?.onStateChanged.update(.fullScreenError(failure.reason))
                    return
                }
                self?.onStateChanged.update(.inlineError(regexLintError))
            }
        }
    }
}

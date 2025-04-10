import UIKit

final class LoginBuilder {
    func build() -> UIViewController {
        let useCase = LoginUseCase(
            apiSession: APISession.shared,
            sessionLocalDataSource: SessionLocalDataSource.shared
        )
        let viewModel = LoginViewModel(loginUseCase: useCase)
        let controller = LoginController(loginViewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}

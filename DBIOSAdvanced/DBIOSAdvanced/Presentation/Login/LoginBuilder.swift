import UIKit

final class LoginBuilder {
    func build() -> UIViewController {
        let useCase = LoginUseCase()
        let viewModel = LoginViewModel(loginUseCase: useCase)
        let controller = LoginController(loginViewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}

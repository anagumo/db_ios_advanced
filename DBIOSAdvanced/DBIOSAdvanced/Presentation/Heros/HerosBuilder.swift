import UIKit

final class HerosBuilder {
    func build() -> UIViewController {
        let viewModel = HerosViewModel(
            herosUseCase: GetHerosUseCase(),
            sortHerosUseCase: SortHerosUseCase(),
            logoutUseCase: LogoutUseCase()
        )
        let controller = HerosController(herosViewModel: viewModel)
        controller.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}

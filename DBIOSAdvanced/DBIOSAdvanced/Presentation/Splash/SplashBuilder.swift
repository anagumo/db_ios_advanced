import UIKit

// Liskov: Objects of a subclass should be replaceable with objects of the superclass without affecting the correctness of the program
// Builder: Create an object and forget the under details
final class SplashBuilder {
    func build() -> UIViewController {
        let viewModel = SplashViewModel(sessionLocalDataSource: SessionLocalDataSource.shared)
        let controller = SplashController(splashViewModel: viewModel)
        return controller
    }
}

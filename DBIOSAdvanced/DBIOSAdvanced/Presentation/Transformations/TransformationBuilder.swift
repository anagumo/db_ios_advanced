import UIKit

final class TransformationBuilder {
    private var identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func build() -> UIViewController {
        let viewModel = TransformationViewModel(
            identifier: identifier,
            getTransformationUseCase: GetTransformationUseCase()
        )
        let controller = TransformationController(transformationViewModel: viewModel)
        return controller
    }
}

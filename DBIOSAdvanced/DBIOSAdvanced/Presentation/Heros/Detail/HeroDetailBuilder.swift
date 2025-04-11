import UIKit

final class HeroDetailBuilder {
    private let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func build() -> UIViewController {
        let viewModel = HeroDetailViewModel(
            name: name,
            getHerosUseCase: GetHerosUseCase(),
            getLocationsUseCase: GetLocationsUseCase(),
            getTransformationsUseCase: TransformationsUseCase()
        )
        let controller = HeroDetailController(heroDetailViewModel: viewModel)
        return controller
    }
}

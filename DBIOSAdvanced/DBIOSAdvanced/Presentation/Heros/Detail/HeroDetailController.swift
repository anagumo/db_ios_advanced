import UIKit

class HeroDetailController: UIViewController {
    // MARK: - View Model
    private let heroDetailViewModel: HeroDetailViewModel
    
    // MARK: - Lifecycle
    init(heroDetailViewModel: HeroDetailViewModel) {
        self.heroDetailViewModel = heroDetailViewModel
        super.init(nibName: "HeroDetailView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        heroDetailViewModel.load()
    }
    
    // MARK: - Binding
    private func bind() {
        heroDetailViewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .ready:
                self?.renderReady()
            case let .error(message):
                self?.renderError(message)
            }
        }
    }
    
    // MARK: - Rendering State
    private func renderReady() {
        title = heroDetailViewModel.hero?.name
    }
    
    private func renderError(_ message: String) {
        present(
            AlertBuilder().build(title: "Error", message: message),
            animated: true
        )
    }
}

// MARK: - UI Configuration
extension HeroDetailController {}

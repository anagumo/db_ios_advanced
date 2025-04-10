import UIKit

class HerosController: UIViewController {
    // MARK: - View Model
    private let herosViewModel: HerosViewModelProtocol
    
    // MARK: - Lifecycle
    init(herosViewModel: HerosViewModel) {
        self.herosViewModel = herosViewModel
        super.init(nibName: "HerosView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIComponents()
        bind()
    }
    
    // MARK: - Binding
    private func bind() {
        herosViewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .loading:
                // TODO: Render loading
                break
            case .ready:
                // TODO: Render ready
                break
            case .logout:
                self?.renderLogout()
            case .error:
                // TODO: Render error
                break
            }
        }
    }
    
    // MARK: - Rendering State
    private func renderLogout() {
        dismiss(animated: true)
    }
}

// MARK: - UI Components Configuration
extension HerosController {
    private func configureUIComponents() {
        title = "Heros"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "power.circle.fill"),
            primaryAction: UIAction { uiAction in
                self.herosViewModel.logout()
            }
        )
    }
}

import UIKit

class HerosController: UIViewController {
    // MARK: - UI Components
    @IBOutlet private weak var errorStackView: UIStackView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
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
        configureUI()
        bind()
        herosViewModel.load()
    }
    
    // MARK: - UI Actions
    @IBAction func onTryAgainButton(_ sender: Any) {
        herosViewModel.load()
    }
    
    // MARK: - Binding
    private func bind() {
        herosViewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .loading:
                self?.renderLoading()
            case .ready:
                self?.renderReady()
            case .logout:
                self?.renderLogout()
            case let .error(message):
                self?.renderError(message)
            }
        }
    }
    
    // MARK: - Rendering State
    private func renderLoading() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    private func renderReady() {
        activityIndicatorView.stopAnimating()
        errorStackView.isHidden = true
        collectionView.isHidden = false
    }
    
    private func renderLogout() {
        dismiss(animated: true)
    }
    
    private func renderError(_ message: String) {
        activityIndicatorView.stopAnimating()
        collectionView.isHidden = true
        errorStackView.isHidden = false
        errorLabel.text = message
    }
}

// MARK: - UI Configuration
extension HerosController {
    private func configureUI() {
        title = "Heros"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "power.circle.fill"),
            primaryAction: UIAction { uiAction in
                self.herosViewModel.logout()
            }
        )
    }
}

import UIKit

class SplashController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    // MARK: - ViewModel
    private let splashViewModel: SplashViewModelProtocol
    
    // MARK: - Lifecycle
    init(splashViewModel: SplashViewModelProtocol) {
        self.splashViewModel = splashViewModel
        super.init(nibName: "SplashView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        splashViewModel.load()
    }
    
    // MARK: - Binding
    func bind() {
        splashViewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .loading:
                self?.renderLoading()
            case .login:
                self?.renderLogin()
            case .home:
                self?.renderHome()
            }
        }
    }
    
    // MARK: - State rendering
    private func renderLoading() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    private func renderLogin() {
        activityIndicatorView.stopAnimating()
        // TODO: Build Login
    }
    
    private func renderHome() {
        activityIndicatorView.stopAnimating()
        // TODO: Build Home
    }
}

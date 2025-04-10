import UIKit

class LoginController: UIViewController {
    // MARK: - UIComponents
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var usernameErrorLabel: UILabel!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    
    // MARK: - View Model
    private var loginViewModel: LoginViewModelProtocol
    
    // MARK: - Lifecycle
    init(loginViewModel: LoginViewModelProtocol) {
        self.loginViewModel = loginViewModel
        super.init(nibName: "LoginView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    // MARK: - Component Actions
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        loginViewModel.login(
            username: usernameTextField.text,
            password: passwordTextField.text
        )
    }
    
    // MARK: - Binding
    private func bind() {
        loginViewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .loading:
                self?.renderLoading()
            case .ready:
                self?.renderReady()
            case let .fullScreenError(message):
                self?.renderFullScreenError(message)
            case let .inlineError(regexLintError):
                self?.renderInlineError(regexLintError)
            }
        }
    }
    
    // MARK: - Rendering state
    private func renderLoading() {
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        loginButton.configuration?.showsActivityIndicator = true
    }
    
    private func renderReady() {
        loginButton.configuration?.showsActivityIndicator = false
        // TODO: Build Home
    }
    
    private func renderFullScreenError(_ errorMessage: String) {
        loginButton.configuration?.showsActivityIndicator = false
        present(
            AlertBuilder().build(title: "Error", message: errorMessage),
            animated: true
        )
    }
    
    private func renderInlineError(_ regexLintError: RegexLintError) {
        loginButton.configuration?.showsActivityIndicator = false
        if regexLintError == .email {
            usernameErrorLabel.text = regexLintError.errorDescription
            usernameErrorLabel.isHidden = false
        } else if regexLintError == .password {
            passwordErrorLabel.text = regexLintError.errorDescription
            passwordErrorLabel.isHidden = false
        }
    }
}

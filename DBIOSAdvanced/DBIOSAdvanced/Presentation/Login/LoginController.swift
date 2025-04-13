import UIKit

final class LoginController: UIViewController {
    // MARK: - UIComponents
    @IBOutlet weak var contentStackView: UIStackView!
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
        configureKeyboardDismiss()
        bind()
    }
    
    private func configureKeyboardDismiss() {
        passwordTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Component Actions
    @IBAction func onLoginButtonTapped(_ sender: Any) {
        loginViewModel.login(
            username: usernameTextField.text,
            password: passwordTextField.text
        )
    }
    
    @objc func onViewTapped(_ sender: Any) {
        view.endEditing(true)
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
        usernameTextField.text = ""
        passwordTextField.text = ""
        present(HerosBuilder().build(), animated: true)
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

// MARK: - TextField Delegate
extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onViewTapped(self)
        onLoginButtonTapped(self)
        return true
    }
}

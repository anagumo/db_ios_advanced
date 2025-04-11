import UIKit

final class TransformationController: UIViewController {
    // MARK: - UI Components
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UITextView!
    // MARK: - View Model
    private let transformationViewModel: TransformationViewModelProtocol
    
    // MARK: - Lifecycle
    init(transformationViewModel: TransformationViewModelProtocol) {
        self.transformationViewModel = transformationViewModel
        super.init(nibName: "TransformationView", bundle: Bundle(for: type(of: self)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        transformationViewModel.load()
    }
    
    // MARK: - Binding
    private func bind() {
        transformationViewModel.onStateChanged.bind { [weak self] state in
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
        let transformation = transformationViewModel.get()
        title = transformation?.name
        photoImageView.setImage(stringURL: transformation?.photo ?? "")
        infoLabel.text = transformation?.info
    }
    
    private func renderError(_ message: String) {
        present(
            AlertBuilder().build(title: "Error", message: message),
            animated: true
        )
    }
}

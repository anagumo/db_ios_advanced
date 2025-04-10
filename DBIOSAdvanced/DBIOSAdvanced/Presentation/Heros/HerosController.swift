import UIKit

class HerosController: UIViewController {
    // MARK: - UI Components
    @IBOutlet private weak var errorStackView: UIStackView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Data Source
    typealias DataSource = UICollectionViewDiffableDataSource<HeroSection, Hero>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HeroSection, Hero>
    private var dataSource: DataSource?
    typealias CellRegistration = UICollectionView.CellRegistration<HeroCell, Hero>
    
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
        configureCollectionView()
        bind()
        herosViewModel.load()
    }
    
    // MARK: - UI Actions
    @IBAction func onTryAgainButton(_ sender: Any) {
        herosViewModel.load()
    }
    
    private func configureCollectionView() {
        // Register cell
        let cellNib = UINib(nibName: HeroCell.identifier, bundle: Bundle(for: type(of: self)))
        let cellRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, item in
            cell.bind(item)
        }
        // Create data source
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        })
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
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
        // Update collection view data source
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(herosViewModel.getAll())
        dataSource?.apply(snapshot)
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
    enum HeroSection {
        case main
    }
    
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

// MARK: - Collection View Delegates
extension HerosController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (collectionView.frame.size.width - 60) / 2
            return CGSize(width: width, height: 200)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let hero = herosViewModel.getHero(position: indexPath.row),
            let heroName = hero.name else {
            return
        }
        show(HeroDetailBuilder(name: heroName).build(), sender: self)
    }
}

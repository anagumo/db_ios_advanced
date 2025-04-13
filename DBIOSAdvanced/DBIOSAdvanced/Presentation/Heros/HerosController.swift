import UIKit

final class HerosController: UIViewController {
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
    
    //MARK: - Search
    private var searchController: UISearchController?
    
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
        configureSearchController()
        configureCollectionView()
        bind()
        herosViewModel.load()
    }
    
    // MARK: - UI Actions
    @IBAction func onTryAgainButton(_ sender: Any) {
        herosViewModel.load()
    }
    
    // Configure a search bar to filter heros
    private func configureSearchController() {
        // Create the search controller and set this screen as search result container
        searchController = UISearchController(searchResultsController: nil)
        // Set the responsability to this controller of any text changes within search bar and update results
        searchController?.searchResultsUpdater = self
        // Set off the property that obscures the screen while searching
        searchController?.obscuresBackgroundDuringPresentation = false
        // Place search bar in the navigation bar since is not compatible do this from IB
        navigationItem.searchController = searchController
        // Changes the search bar text color to white, set after set the controller
        //searchController?.searchBar.searchTextField.textColor = .white
        // Dispaly the search bar always
        navigationItem.hidesSearchBarWhenScrolling = false
        // Hide the search bar when user navigates to another screen
        definesPresentationContext = true
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
            case .sorted:
                self?.renderSorted()
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
        navigationItem.leftBarButtonItem?.isEnabled = herosViewModel.getCount() > 0
        applySnapshot(herosViewModel.getAll())
    }
    
    private func renderSorted() {
        applySnapshot(herosViewModel.getAll())
    }
    
    private func renderLogout() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.window?.rootViewController = LoginBuilder().build()
    }
    
    private func renderError(_ message: String) {
        activityIndicatorView.stopAnimating()
        collectionView.isHidden = true
        errorStackView.isHidden = false
        errorLabel.text = message
    }
    
    private func applySnapshot(_ heroList: [Hero]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(heroList)
        dataSource?.apply(snapshot)
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            primaryAction: UIAction { uiAction in
                self.herosViewModel.sort()
            }
        )
        navigationItem.leftBarButtonItem?.isEnabled = false
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
            let hero = herosViewModel.get(by: indexPath.row),
            let heroName = hero.name else {
            return
        }
        show(HeroBuilder(name: heroName).build(), sender: self)
    }
}

// MARK: Search Controller Delegates
extension HerosController: UISearchResultsUpdating {
    
    /// Update search results based on the text entered in the search bar
    /// - Parameter searchController: a controller of type `(UISearchController)` that represent an instance of the search bar
    func updateSearchResults(for searchController: UISearchController) {
        guard let inputText = searchController.searchBar.text, !inputText.isEmpty else {
            // Restore the data source after clearing the search
            applySnapshot(herosViewModel.getAll())
            return
        }
        applySnapshot(herosViewModel.filter(by: inputText))
    }
}

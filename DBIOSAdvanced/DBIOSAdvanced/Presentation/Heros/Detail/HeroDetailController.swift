import UIKit
import MapKit

enum TransformationSection {
    case main
}

class HeroDetailController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var locationsMapView: MKMapView!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var transformationsCollectionView: UICollectionView!
    // MARK: - View Model
    private let heroDetailViewModel: HeroDetailViewModelProtocol
    // MARK: - Data Source
    typealias DataSource = UICollectionViewDiffableDataSource<TransformationSection, Transformation>
    typealias Snapshot = NSDiffableDataSourceSnapshot<TransformationSection, Transformation>
    typealias CellRegistration = UICollectionView.CellRegistration<TransformationCell, Transformation>
    private var dataSource: DataSource?
    
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
        configureCollectionView()
        locationsMapView.delegate = self
        bind()
        heroDetailViewModel.load()
    }
    
    private func configureCollectionView() {
        let cellNib = UINib(nibName: TransformationCell.identifier, bundle: Bundle(for: type(of: self)))
        let cellRegistration = CellRegistration(cellNib: cellNib) { cell, indexPath, item in
            cell.bind(item)
        }
        
        dataSource = DataSource(collectionView: transformationsCollectionView, cellProvider: { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        })
        
        transformationsCollectionView.dataSource = dataSource
        transformationsCollectionView.delegate = self
    }
    
    // MARK: - Binding
    private func bind() {
        heroDetailViewModel.onStateChanged.bind { [weak self] state in
            switch state {
            case .ready:
                self?.renderReady()
            case .locations:
                self?.renderLocations()
            case .transformations:
                self?.renderTransformations()
            case let .error(message):
                self?.renderError(message)
            }
        }
    }
    
    // MARK: - Rendering State
    private func renderReady() {
        let hero = heroDetailViewModel.get()
        title = hero?.name
        infoLabel.text = hero?.info
        heroDetailViewModel.loadLocations()
        heroDetailViewModel.loadTransformations()
    }
    
    private func renderLocations() {
        // Add annotations
        let annotations = locationsMapView.annotations
        if !annotations.isEmpty {
            locationsMapView.removeAnnotations(annotations)
        }
        locationsMapView.addAnnotations(heroDetailViewModel.getMapAnnotations())
        
        // Center to location
        guard let region = heroDetailViewModel.getMapRegion() else {
            return
        }
        
        locationsMapView.setRegion(region, animated: true)
    }
    
    private func renderTransformations() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(heroDetailViewModel.getTransformations())
        dataSource?.apply(snapshot)
        transformationsCollectionView.isHidden = false
    }
    
    private func renderError(_ message: String) {
        present(
            AlertBuilder().build(title: "Error", message: message),
            animated: true
        )
    }
}

// MARK: - MKMapView Delegate
extension HeroDetailController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        guard annotation is HeroAnnotation else {
            return nil
        }
        
        guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: HeroAnnotationView.identifier) else {
            return HeroAnnotationView(annotation: annotation, reuseIdentifier: HeroAnnotationView.identifier)
        }
        
        return view
    }
}

// MARK: - Collection View Delegates
extension HeroDetailController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 150, height: 150)
        }
}

import UIKit
import MapKit

class HeroDetailController: UIViewController {
    // MARK: - View Model
    @IBOutlet weak var locationsMapView: MKMapView!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var transformationsCollectionView: UICollectionView!
    private let heroDetailViewModel: HeroDetailViewModelProtocol
    
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
        locationsMapView.delegate = self
        bind()
        heroDetailViewModel.load()
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
        let annotations = locationsMapView.annotations
        if !annotations.isEmpty {
            locationsMapView.removeAnnotations(annotations)
        }
        locationsMapView.addAnnotations(heroDetailViewModel.getMapAnnotations())
    }
    
    private func renderTransformations() {
        // TODO: Render transformations
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

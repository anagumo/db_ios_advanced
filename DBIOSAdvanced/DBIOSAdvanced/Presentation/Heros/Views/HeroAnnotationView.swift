import Foundation
import MapKit

final class HeroAnnotationView: MKAnnotationView {
    static let identifier = String(describing: HeroAnnotationView.self)
    
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.canShowCallout = true
        self.backgroundColor = .clear
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        let imageView = UIImageView(image: UIImage(resource: .dragonBall))
        self.addSubview(imageView)
        imageView.frame = bounds
    }
}

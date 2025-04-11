import Foundation
import MapKit

class HeroAnnotation: NSObject,  MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(
        coordinate: CLLocationCoordinate2D,
        title: String? = nil,
        subtitle: String? = nil
    ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

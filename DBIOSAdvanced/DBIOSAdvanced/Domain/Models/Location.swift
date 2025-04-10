import Foundation
import MapKit

struct Location {
    let identifier: String
    let longitude: String?
    let latitude: String?
    let date: String?
    let hero: Hero?
}

extension Location {
    
    var coordinate: CLLocationCoordinate2D? {
        guard
            let latitude,
            let longitude,
            let lat = Double(latitude),
            let lon = Double(longitude) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

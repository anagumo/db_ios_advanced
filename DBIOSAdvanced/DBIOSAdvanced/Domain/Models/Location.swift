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
    
    var annotation: HeroAnnotation? {
        guard let coordinate = coordinate else {
            return nil
        }
        
        return HeroAnnotation(
            coordinate: coordinate,
            title: hero?.name,
            subtitle: date
        )
    }
    
    var region: MKCoordinateRegion? {
        guard let coordinate else {
            return nil
        }
        
        return MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 100_000,
            longitudinalMeters: 100_000
        )
    }
}

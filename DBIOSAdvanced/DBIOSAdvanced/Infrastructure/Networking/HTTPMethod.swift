import Foundation

enum HTTPMethod: String {
    case get, post
    
    var value: String {
        self.rawValue.uppercased()
    }
}

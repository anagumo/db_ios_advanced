import Foundation
import KeychainSwift

protocol SessionDataSourceProtocol {
    func get() -> String?
    func set(_ jwt: Data)
    func clear()
}

final class SessionDataSource: SessionDataSourceProtocol {
    static let shared = SessionDataSource()
    private let keychainSwift = KeychainSwift()
    private let jwtKey = "jwt"
    
    func get() -> String? {
        return keychainSwift.get(jwtKey)
    }
    
    func set(_ jwt: Data) {
        let jwtString = String(decoding: jwt, as: UTF8.self)
        keychainSwift.set(jwt, forKey: jwtString)
    }
    
    func clear() {
        keychainSwift.clear()
    }
}

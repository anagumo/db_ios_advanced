import Foundation
import KeychainSwift
import OSLog

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
        Logger.log("JWT provided to perform an authorized network request", level: .trace, layer: .repository)
        return keychainSwift.get(jwtKey)
    }
    
    func set(_ jwt: Data) {
        let jwtString = String(decoding: jwt, as: UTF8.self)
        keychainSwift.set(jwt, forKey: jwtString)
        Logger.log("JWT was saved successfully after the user logged in", level: .trace, layer: .repository)
    }
    
    func clear() {
        keychainSwift.clear()
        Logger.log("JWT cleaned successfully", level: .trace, layer: .repository)
    }
}

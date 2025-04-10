import Foundation
import KeychainSwift
import OSLog

protocol SessionLocalDataSourceProtocol {
    func get() -> String?
    func set(_ jwt: Data)
    func clear()
}

final class SessionLocalDataSource: SessionLocalDataSourceProtocol {
    static let shared = SessionLocalDataSource()
    private let keychainSwift = KeychainSwift()
    private let jwtKey = "jwt"
    
    func get() -> String? {
        Logger.log("JWT requested to validate session or perform an authorized network call", level: .trace, layer: .repository)
        return keychainSwift.get(jwtKey)
    }
    
    func set(_ jwt: Data) {
        let jwtString = String(decoding: jwt, as: UTF8.self)
        keychainSwift.set(jwt, forKey: jwtKey)
        Logger.log("JWT was saved successfully after the user logged in \(jwtString)", level: .trace, layer: .repository)
    }
    
    func clear() {
        keychainSwift.clear()
        Logger.log("JWT cleaned successfully", level: .trace, layer: .repository)
    }
}

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
        Logger.log("JWT provided to perform an authorized network request", level: .trace, layer: .repository)
        return "eyJ0eXAiOiJKV1QiLCJraWQiOiJwcml2YXRlIiwiYWxnIjoiSFMyNTYifQ.eyJlbWFpbCI6ImFyaW5hZ3Vtb0BnbWFpbC5jb20iLCJleHBpcmF0aW9uIjo2NDA5MjIxMTIwMCwiaWRlbnRpZnkiOiIyNTc5QzlGNy1BMkVDLTREQUYtQTVGRC0zNzVGN0UwODU1QTgifQ.kzN1Wapf1Rcguxd1losZANHnyEiAxCnkX8tyISp9Dfg"
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

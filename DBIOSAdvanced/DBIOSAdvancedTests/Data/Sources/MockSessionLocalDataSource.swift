import Foundation
@testable import DBIOSAdvanced

final class MockSessionLocalDataSource: SessionLocalDataSourceProtocol {
    
    func get() -> String? {
        UserDefaults.standard.string(forKey: "jwt")
    }
    
    func set(_ jwt: Data) {
        let jwtString = String(decoding: jwt, as: UTF8.self)
        UserDefaults.standard.setValue(jwtString, forKey: "jwt")
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: "jwt")
    }
}

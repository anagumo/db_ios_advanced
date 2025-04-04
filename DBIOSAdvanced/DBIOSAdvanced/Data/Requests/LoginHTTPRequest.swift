import Foundation

struct LoginHTTPRequest: HTTPRequestComponents {
    var path: String = "/api/auth/login"
    var method: HTTPMethod = .POST
    var headers: [String : String]
    typealias Response = Data
    
    init(username: String, password: String) {
        let loginCredentials = String(format: "%@:%@", username, password)
        let loginData = Data(loginCredentials.utf8)
        let base64LoginData = loginData.base64EncodedString()
        headers = [
            "Authorization": "Basic \(base64LoginData)"
        ]
    }
}

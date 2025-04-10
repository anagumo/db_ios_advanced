import Foundation
import OSLog

protocol LoginUseCaseProtocol {
    func run(username: String?, password: String?, completion: @escaping (Result<Void, PresentationError>) -> Void)
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let apiSession: APISessionProtocol
    private let sessionLocalDataSource: SessionLocalDataSourceProtocol
    
    init(apiSession: APISessionProtocol, sessionLocalDataSource: SessionLocalDataSourceProtocol) {
        self.apiSession = apiSession
        self.sessionLocalDataSource = sessionLocalDataSource
    }
    
    func run(username: String?, password: String?, completion: @escaping (Result<Void, PresentationError>) -> Void) {
        do {
            let username = try RegexLint.validate(data: username ?? "", matchWith: .email)
            let password = try RegexLint.validate(data: password ?? "", matchWith: .password)
            Logger.log("Valid format credentials for \(username) and \(password)", level: .debug, layer: .domain)
            
            let loginHTTPRequest = LoginHTTPRequest(username: username, password: password)
            apiSession.request(loginHTTPRequest) { [weak self] result in
                do {
                    let jwtData = try result.get()
                    self?.sessionLocalDataSource.set(jwtData)
                    Logger.log("User logged in", level: .info, layer: .domain)
                    completion(.success(()))
                } catch let error as APIError {
                    Logger.log("\(error.reason)", level: .error, layer: .domain)
                    completion(.failure(.network(error.reason)))
                } catch {
                    Logger.log("Unknown login error", level: .error, layer: .domain)
                    completion(.failure(.uknown()))
                }
            }
        } catch let error as RegexLintError {
            Logger.log("Invalid format credentials for \(String(describing: username)) and \(String(describing: password))", level: .debug, layer: .domain)
            completion(.failure(.regex(error)))
        } catch {
            Logger.log("Unknown login error", level: .error, layer: .domain)
            completion(.failure(.uknown()))
        }
    }
}

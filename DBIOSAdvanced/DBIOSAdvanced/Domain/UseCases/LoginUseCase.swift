import Foundation

protocol LoginUseCaseProtocol {
    func run(username: String, password: String, completion: @escaping (Result<Hero, LoginError>) -> Void)
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let apiSession: APISessionProtocol
    private let sessionLocalDataSource: SessionLocalDataSourceProtocol
    
    init(apiSession: APISessionProtocol, sessionLocalDataSource: SessionLocalDataSourceProtocol) {
        self.apiSession = apiSession
        self.sessionLocalDataSource = sessionLocalDataSource
    }
    
    func run(username: String, password: String, completion: @escaping (Result<Hero, LoginError>) -> Void) {
        do {
            let username = try RegexLint.validate(data: username, matchWith: .email)
            let password = try RegexLint.validate(data: password, matchWith: .password)
            
            let loginHTTPRequest = LoginHTTPRequest(username: username, password: password)
            apiSession.request(loginHTTPRequest) { [weak self] result in
                do {
                    let jwtData = try result.get()
                    self?.sessionLocalDataSource.set(jwtData)
                } catch let error as APIError {
                    completion(.failure(.network(error.reason)))
                } catch {
                    completion(.failure(LoginError.uknown()))
                }
            }
        } catch let error as RegexLintError {
            completion(.failure(.regex(error)))
        } catch {
            completion(.failure(.uknown()))
        }
    }
}

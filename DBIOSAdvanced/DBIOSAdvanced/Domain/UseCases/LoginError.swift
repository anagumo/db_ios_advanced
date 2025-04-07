import Foundation

struct LoginError: Error, Equatable {
    let reason: String
    let regex: RegexLintError?
    
    init(reason: String, regex: RegexLintError? = nil) {
        self.reason = reason
        self.regex = regex
    }
}

extension LoginError {
    /// Describes a regex error in the input data
    /// - Parameter error: an enum case of type (`RegexLintErro+`–)  that represents the regex pattern
    /// - Returns: an object of type (`LoginError`) to encapsulate a message and type of input error
    static func regex(_ error: RegexLintError) -> LoginError {
        LoginError(reason: "Regex error", regex: error)
    }
    
    /// Describes a network error in the api client
    /// - Parameter error: an object of type (`APIErrorResponse`) that represents an api error
    /// - Returns: an object of type (`LoginError`) that encapsulate an error message
    static func network(_ errorMessage: String) -> LoginError {
        LoginError(reason: errorMessage)
    }
    
    /// Describes an unknow login error
    /// - Returns: - Returns: an object of type (`LoginError`) that encapsulate an error message
    static func uknown() -> LoginError {
        LoginError(reason: "Login unknown error")
    }
}

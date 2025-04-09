import Foundation

struct PresentationError: Error, Equatable {
    let reason: String
    let regex: RegexLintError?
    
    init(reason: String, regex: RegexLintError? = nil) {
        self.reason = reason
        self.regex = regex
    }
}

extension PresentationError {
    /// Describes a regex error in the input data
    /// - Parameter error: an enum case of type (`RegexLintErro+`–)  that represents the regex pattern
    /// - Returns: an object of type (`PresentationError`) to encapsulate a message and type of input error
    static func regex(_ error: RegexLintError) -> Self {
        PresentationError(reason: "Regex error", regex: error)
    }
    
    /// Describes an empty hero list error
    /// - Returns: an object of type (`PresentationError`) that encapsulate an error message
    static func emptyList() -> Self {
        PresentationError(reason: "Empty entity list")
    }
    
    /// Describes an empty hero error
    /// - Returns: an object of type (`PresentationError`) that encapsulate an error message
    static func notFound() -> Self {
        PresentationError(reason: "Entity not found")
    }
    
    /// Describes an empty hero error
    /// - Returns: an object of type (`PresentationError`) that encapsulate an error message
    static func session() -> Self {
        PresentationError(reason: "Session not found")
    }
    
    /// Describes a network error in the api client
    /// - Parameter error: an object of type (`String`) that represents an api error
    /// - Returns: an object of type (`PresentationError`) that encapsulate an error message
    static func network(_ errorMessage: String) -> Self {
        PresentationError(reason: errorMessage)
    }
    
    /// Describes an unknow login error
    /// - Returns: - Returns: an object of type (`PresentationError`) that encapsulate an error message
    static func uknown() -> Self {
        PresentationError(reason: "Unknown error")
    }
}

import Foundation

struct HeroError: Error {
    let reason: String
}

extension HeroError {
    /// Describes an empty hero list error
    /// - Returns: an object of type (`HeroError`) that encapsulate an error message
    static func emptyList() -> HeroError {
        HeroError(reason: "Empty hero list")
    }
    
    /// Describes an empty hero error
    /// - Returns: an object of type (`HeroError`) that encapsulate an error message
    static func notFound() -> HeroError {
        HeroError(reason: "Hero not found")
    }
    
    /// Describes a network error in the api client
    /// - Parameter error: an object of type (`APIErrorResponse`) that represents an api error
    /// - Returns: an object of type (`HeroError`) that encapsulate an error message
    static func network(_ errorMessage: String) -> HeroError {
        HeroError(reason: errorMessage)
    }
    
    /// Describes an unknow login error
    /// - Returns: - Returns: an object of type (`HeroError`) that encapsulate an error message
    static func uknown() -> HeroError {
        HeroError(reason: "Hero unknown error")
    }
}

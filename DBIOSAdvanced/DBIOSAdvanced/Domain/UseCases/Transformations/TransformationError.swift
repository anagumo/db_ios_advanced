import Foundation

struct AppError: Error {
    let reason: String
}

extension AppError {
    /// Describes an empty hero list error
    /// - Returns: an object of type (`AppError`) that encapsulate an error message
    static func emptyList() -> Self {
        AppError(reason: "Empty list")
    }
    
    /// Describes an empty hero error
    /// - Returns: an object of type (`AppError`) that encapsulate an error message
    static func notFound() -> Self {
        AppError(reason: "Not found")
    }
    
    /// Describes a network error in the api client
    /// - Parameter error: an object of type (`String`) that represents an api error
    /// - Returns: an object of type (`AppError`) that encapsulate an error message
    static func network(_ errorMessage: String) -> Self {
        AppError(reason: errorMessage)
    }
    
    /// Describes an unknow login error
    /// - Returns: - Returns: an object of type (`AppError`) that encapsulate an error message
    static func uknown() -> Self {
        AppError(reason: "Unknown error")
    }
}

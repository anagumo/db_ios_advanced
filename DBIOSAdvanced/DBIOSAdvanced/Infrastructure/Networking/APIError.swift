import Foundation

struct APIError: Error {
    let url: String
    let reason: String
    let statusCode: Int?
    
    init(url: String, reason: String, statusCode: Int? = nil) {
        self.url = url
        self.reason = reason
        self.statusCode = statusCode
    }
}

extension APIError {
    
    static func malformedURL(url: String) -> Self {
        APIError(
            url: url,
            reason: "Malformed URL"
        )
    }
    
    static func badRequest(url: String) -> Self {
        APIError(
            url: url,
            reason: "Bad request"
        )
    }
    
    static func server(url: String, statusCode: Int?) -> Self {
        APIError(
            url: url,
            reason: "There was a server error",
            statusCode: statusCode
        )
    }
    
    static func noData(url: String, statusCode: Int?) -> Self {
        APIError(
            url: url,
            reason: "No data provided",
            statusCode: statusCode
        )
    }
    
    static func decoding(url: String) -> Self {
        APIError(url: url, reason: "Decoding failed")
    }
    
    static func unauthorized(url: String, statusCode: Int?) -> Self {
        APIError(
            url: url,
            reason: "Wrong email or password. Please log in again.",
            statusCode: statusCode
        )
    }
    
    static func unknown(url: String) -> Self {
        APIError(
            url: url,
            reason: "Unknown server error"
        )
    }
}

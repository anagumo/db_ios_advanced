import OSLog

enum LogLevel {
    case trace // For tracing execution or debuggin a behaivor
    case debug // For debuggin something in development mode
    case info // For meaninful events to understand how user interact with the app
    case notice // Important changes but not necessary an error or warning
    case warning // For unexpected things like edge cases
    case error // For bugs or expected failures like networks issues or db errors
    case critical // For several issues that will likely crash or impact the app
}

enum LogCategory: String {
    case infraestructure
    case repository
    case domain
    case presentation
    
    var logger: Logger {
        switch self {
        case .infraestructure:
            Logger(subsystem: "DBIOSAdvanced", category: self.rawValue)
        case .repository:
            Logger(subsystem: "DBIOSAdvanced", category: self.rawValue)
        case .domain:
            Logger(subsystem: "DBIOSAdvanced", category: self.rawValue)
        case .presentation:
            Logger(subsystem: "DBIOSAdvanced", category: self.rawValue)
        }
    }
}

extension Logger {
    static let shared = Logger()
    
    static func log(_ message: String,
                    level: LogLevel,
                    layer: LogCategory,
                    file: String = #file,
                    line: Int = #line,
                    function: String = #function
    ) {
        let fileName = (file as NSString).lastPathComponent
        let finalMessage = "[\(layer.rawValue.capitalized)] [\(fileName):\(line)] \(function) -> \(message)"
        switch level {
        case .trace:
            layer.logger.trace("🐾 \(finalMessage)")
        case .debug:
            layer.logger.debug("🐛 \(finalMessage)")
        case .info:
            layer.logger.info("ℹ️ \(finalMessage)")
        case .notice:
            layer.logger.notice("🔎 \(finalMessage)")
        case .warning:
            layer.logger.warning("⚠️ \(finalMessage)")
        case .error:
            layer.logger.error("❌ \(finalMessage)")
        case .critical:
            layer.logger.critical("🚨 \(finalMessage)")
        }
    }
}


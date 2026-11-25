import Foundation

enum AppConfigurationError: Error, Equatable, LocalizedError {
    case missingAPIBaseURL
    case invalidAPIBaseURL(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIBaseURL:
            return "API_BASE_URL is missing from the application configuration."
        case let .invalidAPIBaseURL(value):
            return "API_BASE_URL is not a valid HTTP or HTTPS URL: \(value)"
        }
    }
}

struct AppConfiguration: Sendable {
    let apiBaseURL: URL

    init(infoDictionary: [String: Any]) throws {
        guard let value = infoDictionary["API_BASE_URL"] as? String, !value.isEmpty else {
            throw AppConfigurationError.missingAPIBaseURL
        }
        guard
            let url = URL(string: value),
            let scheme = url.scheme?.lowercased(),
            scheme == "http" || scheme == "https",
            url.host != nil
        else {
            throw AppConfigurationError.invalidAPIBaseURL(value)
        }
        apiBaseURL = url
    }

    static func live(bundle: Bundle = .main) throws -> AppConfiguration {
        try AppConfiguration(infoDictionary: bundle.infoDictionary ?? [:])
    }
}

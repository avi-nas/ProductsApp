import Foundation

enum APIError: Error, Equatable, LocalizedError, Sendable {
    case invalidRequest
    case encoding
    case transport
    case invalidResponse
    case decoding
    case server(statusCode: Int, code: String, message: String, details: [String: [String]]?)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "The request could not be created."
        case .encoding:
            return "The request could not be encoded."
        case .transport:
            return "The server could not be reached."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decoding:
            return "The server response could not be read."
        case let .server(_, _, message, _):
            return message
        }
    }
}

import Foundation
@testable import ProductsApp

enum TestSupportError: Error {
    case responseCreationFailed
}

actor MockHTTPClient: HTTPClient {
    typealias Handler = @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    private let handler: Handler
    private var requests: [URLRequest] = []

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        return try await handler(request)
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

func makeHTTPResponse(url: URL, statusCode: Int = 200) throws -> HTTPURLResponse {
    guard let response = HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: ["Content-Type": "application/json"]
    ) else {
        throw TestSupportError.responseCreationFailed
    }
    return response
}

let productJSON = """
{
  "id": 1,
  "title": "Backpack",
  "price": 109.95,
  "description": "Everyday backpack",
  "category": "men's clothing",
  "imageUrl": "https://example.test/product.png",
  "rating": { "rate": 3.9, "count": 120 }
}
"""

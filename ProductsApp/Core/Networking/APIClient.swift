import Foundation

struct APIClient: Sendable {
    private static let pathSegmentAllowed = CharacterSet.alphanumerics.union(
        CharacterSet(charactersIn: "-._~")
    )

    private let baseURL: URL
    private let httpClient: any HTTPClient

    init(baseURL: URL, httpClient: any HTTPClient) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }

    func get<Response: Decodable>(
        path: [String],
        queryItems: [URLQueryItem] = [],
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        try await send(path: path, queryItems: queryItems, method: "GET", body: nil, as: responseType)
    }

    func post<Body: Encodable, Response: Decodable>(
        path: [String],
        body: Body,
        as responseType: Response.Type = Response.self
    ) async throws -> Response {
        let encodedBody: Data
        do {
            encodedBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encoding
        }
        return try await send(path: path, method: "POST", body: encodedBody, as: responseType)
    }

    private func send<Response: Decodable>(
        path: [String],
        queryItems: [URLQueryItem] = [],
        method: String,
        body: Data?,
        as responseType: Response.Type
    ) async throws -> Response {
        let request = try makeRequest(path: path, queryItems: queryItems, method: method, body: body)

        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await httpClient.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport
        }

        guard (200 ... 299).contains(response.statusCode) else {
            let backendError = try? JSONDecoder().decode(APIErrorEnvelopeDTO.self, from: data)
            throw APIError.server(
                statusCode: response.statusCode,
                code: backendError?.error.code ?? "HTTP_\(response.statusCode)",
                message: backendError?.error.message ?? "The server returned an error.",
                details: backendError?.error.details
            )
        }

        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private func makeRequest(
        path: [String],
        queryItems: [URLQueryItem],
        method: String,
        body: Data?
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidRequest
        }

        let encodedSegments = try path.map { segment in
            guard let encoded = segment.addingPercentEncoding(withAllowedCharacters: Self.pathSegmentAllowed)
            else {
                throw APIError.invalidRequest
            }
            return encoded
        }
        let basePath = components.percentEncodedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.percentEncodedPath = "/" + ([basePath] + encodedSegments)
            .filter { !$0.isEmpty }
            .joined(separator: "/")
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw APIError.invalidRequest
        }

        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}

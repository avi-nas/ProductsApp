import Foundation
import XCTest
@testable import ProductsApp

final class APIClientTests: XCTestCase {
    func testDecodesSuccessEnvelopeAndBuildsEncodedRequest() async throws {
        let body = Data("{\"data\":[\"electronics\"]}".utf8)
        let httpClient = MockHTTPClient { request in
            (body, try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/")))
        }
        let client = APIClient(
            baseURL: try XCTUnwrap(URL(string: "http://127.0.0.1:3000")),
            httpClient: httpClient
        )

        let envelope: APIEnvelopeDTO<[String]> = try await client.get(
            path: ["api", "v1", "categories", "men's clothing", "products"],
            queryItems: [URLQueryItem(name: "q", value: "winter jacket")]
        )

        XCTAssertEqual(envelope.data, ["electronics"])
        let requests = await httpClient.recordedRequests()
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(
            request.url?.absoluteString,
            "http://127.0.0.1:3000/api/v1/categories/men%27s%20clothing/products?q=winter%20jacket"
        )
        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testDecodesBackendErrorDetails() async throws {
        let body = Data("""
        {"error":{"code":"VALIDATION_ERROR","message":"The request is invalid.","details":{"q":["q is required"]}}}
        """.utf8)
        let httpClient = MockHTTPClient { request in
            (body, try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/"), statusCode: 400))
        }
        let client = APIClient(
            baseURL: try XCTUnwrap(URL(string: "http://127.0.0.1:3000")),
            httpClient: httpClient
        )

        do {
            let _: APIEnvelopeDTO<[ProductDTO]> = try await client.get(
                path: ["api", "v1", "products", "search"]
            )
            XCTFail("Expected a server error")
        } catch let error as APIError {
            XCTAssertEqual(
                error,
                .server(
                    statusCode: 400,
                    code: "VALIDATION_ERROR",
                    message: "The request is invalid.",
                    details: ["q": ["q is required"]]
                )
            )
        }
    }

    func testMapsTransportAndDecodingFailures() async throws {
        let transportClient = MockHTTPClient { _ in
            throw URLError(.notConnectedToInternet)
        }
        let decodingClient = MockHTTPClient { request in
            (Data("not-json".utf8), try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/")))
        }
        let baseURL = try XCTUnwrap(URL(string: "http://127.0.0.1:3000"))

        do {
            let _: APIEnvelopeDTO<[String]> = try await APIClient(
                baseURL: baseURL,
                httpClient: transportClient
            ).get(path: ["api", "v1", "categories"])
            XCTFail("Expected a transport error")
        } catch let error as APIError {
            XCTAssertEqual(error, .transport)
        }

        do {
            let _: APIEnvelopeDTO<[String]> = try await APIClient(
                baseURL: baseURL,
                httpClient: decodingClient
            ).get(path: ["api", "v1", "categories"])
            XCTFail("Expected a decoding error")
        } catch let error as APIError {
            XCTAssertEqual(error, .decoding)
        }
    }
}

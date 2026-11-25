import Foundation
import XCTest
@testable import ProductsApp

final class LiveEnquiryRepositoryTests: XCTestCase {
    func testEncodesEnquiryAndRequiresSubmittedTrue() async throws {
        let httpClient = MockHTTPClient { request in
            (
                Data("{\"data\":{\"submitted\":true}}".utf8),
                try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/"))
            )
        }
        let repository = try makeRepository(httpClient: httpClient)

        try await repository.submit(
            EnquirySubmission(
                name: "Asha Patel",
                email: "asha@example.test",
                productID: 1,
                message: "Please contact me."
            )
        )

        let requests = await httpClient.recordedRequests()
        let request = try XCTUnwrap(requests.first)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.path, "/api/v1/enquiries")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
        XCTAssertEqual(json["name"] as? String, "Asha Patel")
        XCTAssertEqual(json["productId"] as? Int, 1)
        XCTAssertEqual(json["message"] as? String, "Please contact me.")
    }

    func testRejectsSubmittedFalse() async throws {
        let httpClient = MockHTTPClient { request in
            (
                Data("{\"data\":{\"submitted\":false}}".utf8),
                try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/"))
            )
        }
        let repository = try makeRepository(httpClient: httpClient)

        do {
            try await repository.submit(
                EnquirySubmission(
                    name: "Asha",
                    email: "asha@example.test",
                    productID: 1,
                    message: nil
                )
            )
            XCTFail("Expected an invalid response error")
        } catch let error as APIError {
            XCTAssertEqual(error, .invalidResponse)
        }
    }

    func testMapsBackendValidationDetailsToDomainError() async throws {
        let body = Data("""
        {"error":{"code":"VALIDATION_ERROR","message":"The request is invalid.","details":{"email":["Email is not accepted."]}}}
        """.utf8)
        let httpClient = MockHTTPClient { request in
            (
                body,
                try makeHTTPResponse(
                    url: request.url ?? URL(fileURLWithPath: "/"),
                    statusCode: 400
                )
            )
        }
        let repository = try makeRepository(httpClient: httpClient)

        do {
            try await repository.submit(
                EnquirySubmission(
                    name: "Asha",
                    email: "invalid@example.test",
                    productID: 1,
                    message: nil
                )
            )
            XCTFail("Expected a domain enquiry error")
        } catch let error as EnquirySubmissionError {
            XCTAssertEqual(error.message, "The request is invalid.")
            XCTAssertEqual(error.fieldErrors[.email], "Email is not accepted.")
        }
    }

    private func makeRepository(httpClient: any HTTPClient) throws -> LiveEnquiryRepository {
        LiveEnquiryRepository(
            apiClient: APIClient(
                baseURL: try XCTUnwrap(URL(string: "http://127.0.0.1:3000")),
                httpClient: httpClient
            )
        )
    }
}

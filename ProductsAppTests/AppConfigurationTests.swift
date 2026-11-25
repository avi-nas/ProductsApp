import XCTest
@testable import ProductsApp

final class AppConfigurationTests: XCTestCase {
    func testLoadsValidBackendURL() throws {
        let configuration = try AppConfiguration(
            infoDictionary: ["API_BASE_URL": "http://127.0.0.1:3000"]
        )

        XCTAssertEqual(configuration.apiBaseURL.absoluteString, "http://127.0.0.1:3000")
    }

    func testRejectsMissingAndUnsupportedURLs() {
        XCTAssertThrowsError(try AppConfiguration(infoDictionary: [:])) { error in
            XCTAssertEqual(error as? AppConfigurationError, .missingAPIBaseURL)
        }
        XCTAssertThrowsError(
            try AppConfiguration(infoDictionary: ["API_BASE_URL": "ftp://example.test"])
        )
    }
}

import Foundation
import XCTest
@testable import ProductsApp

final class LiveCatalogueRepositoryTests: XCTestCase {
    func testImplementsHomeCategoriesAndProductDetail() async throws {
        let httpClient = MockHTTPClient { request in
            let data: Data
            switch request.url?.path {
            case "/api/v1/home":
                data = Data("{\"data\":{\"featuredProducts\":[\(productJSON)]}}".utf8)
            case "/api/v1/categories":
                data = Data("{\"data\":[\"electronics\",\"jewelery\"]}".utf8)
            case "/api/v1/products/1":
                data = Data("{\"data\":\(productJSON)}".utf8)
            default:
                data = Data()
            }
            return (data, try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/")))
        }
        let repository = try makeRepository(httpClient: httpClient)

        let home = try await repository.home()
        let categories = try await repository.categories()
        let product = try await repository.product(id: 1)

        XCTAssertEqual(home.map(\.id), [1])
        XCTAssertEqual(categories, ["electronics", "jewelery"])
        XCTAssertEqual(product.title, "Backpack")
    }

    func testPreservesCategorySectionsAndEncodesCategoryPath() async throws {
        let responseBody = """
        {"data":{"category":"men's clothing","topRated":[\(productJSON)],"additional":[]}}
        """
        let httpClient = MockHTTPClient { request in
            (Data(responseBody.utf8), try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/")))
        }
        let repository = try makeRepository(httpClient: httpClient)

        let category = try await repository.category("men's clothing")

        XCTAssertEqual(category.category, "men's clothing")
        XCTAssertEqual(category.topRated.map(\.id), [1])
        XCTAssertEqual(category.additional, [])
        let requests = await httpClient.recordedRequests()
        XCTAssertEqual(
            requests.first?.url?.absoluteString,
            "http://127.0.0.1:3000/api/v1/categories/men%27s%20clothing/products"
        )
    }

    func testSearchUsesQueryItemAndMapsResults() async throws {
        let httpClient = MockHTTPClient { request in
            (
                Data("{\"data\":[\(productJSON)]}".utf8),
                try makeHTTPResponse(url: request.url ?? URL(fileURLWithPath: "/"))
            )
        }
        let repository = try makeRepository(httpClient: httpClient)

        let products = try await repository.search("winter jacket")

        XCTAssertEqual(products.map(\.id), [1])
        let requests = await httpClient.recordedRequests()
        XCTAssertEqual(requests.first?.url?.query, "q=winter%20jacket")
    }

    private func makeRepository(httpClient: any HTTPClient) throws -> LiveCatalogueRepository {
        LiveCatalogueRepository(
            apiClient: APIClient(
                baseURL: try XCTUnwrap(URL(string: "http://127.0.0.1:3000")),
                httpClient: httpClient
            )
        )
    }
}

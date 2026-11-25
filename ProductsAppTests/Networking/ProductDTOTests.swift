import Foundation
import XCTest
@testable import ProductsApp

final class ProductDTOTests: XCTestCase {
    func testMapsProductWithRatingToDomain() throws {
        let dto = try JSONDecoder().decode(ProductDTO.self, from: Data(productJSON.utf8))
        let product = dto.toDomain()

        XCTAssertEqual(product.id, 1)
        XCTAssertEqual(product.imageURL.absoluteString, "https://example.test/product.png")
        XCTAssertEqual(product.rating, Rating(rate: 3.9, count: 120))
    }

    func testAcceptsExplicitNullRating() throws {
        let json = productJSON.replacingOccurrences(
            of: "{ \"rate\": 3.9, \"count\": 120 }",
            with: "null"
        )

        let dto = try JSONDecoder().decode(ProductDTO.self, from: Data(json.utf8))

        XCTAssertNil(dto.rating)
    }

    func testRejectsMissingRatingKey() {
        let json = """
        {
          "id": 1,
          "title": "Backpack",
          "price": 109.95,
          "description": "Everyday backpack",
          "category": "men's clothing",
          "imageUrl": "https://example.test/product.png"
        }
        """

        XCTAssertThrowsError(
            try JSONDecoder().decode(ProductDTO.self, from: Data(json.utf8))
        )
    }
}

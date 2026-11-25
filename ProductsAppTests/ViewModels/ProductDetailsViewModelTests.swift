import XCTest
@testable import ProductsApp

@MainActor
final class ProductDetailsViewModelTests: XCTestCase {
    func testLoadsProductWithNullableRating() async {
        let product = Product.fixture(id: 7, rating: nil)
        let repository = MockCatalogueRepository(product: .success(product))
        let viewModel = ProductDetailsViewModel(productID: 7, repository: repository)

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.state, .loaded(product))
        let productIDs = await repository.recordedProductIDs()
        XCTAssertEqual(productIDs, [7])
    }

    func testFailureCanBeRetried() async {
        let repository = MockCatalogueRepository(product: .failure(.unavailable))
        let viewModel = ProductDetailsViewModel(productID: 7, repository: repository)

        await viewModel.reload()
        await viewModel.reload()

        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }
        let productIDs = await repository.recordedProductIDs()
        XCTAssertEqual(productIDs, [7, 7])
    }
}

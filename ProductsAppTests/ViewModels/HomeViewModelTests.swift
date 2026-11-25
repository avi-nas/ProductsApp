import XCTest
@testable import ProductsApp

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadsFeaturedProductsAndCategoriesTogether() async {
        let products = (1 ... 5).map { Product.fixture(id: $0) }
        let repository = MockCatalogueRepository(
            home: .success(products),
            categories: .success(["electronics", "jewelery"])
        )
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.loadIfNeeded()

        XCTAssertEqual(
            viewModel.state,
            .loaded(HomeContent(featuredProducts: products, categories: ["electronics", "jewelery"]))
        )
    }

    func testFailureProducesRetryableErrorAndRetryCallsAgain() async {
        let repository = MockCatalogueRepository(home: .failure(.unavailable))
        let viewModel = HomeViewModel(repository: repository)

        await viewModel.reload()
        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }
        await viewModel.reload()

        let callCount = await repository.homeCallCount
        XCTAssertEqual(callCount, 2)
    }
}

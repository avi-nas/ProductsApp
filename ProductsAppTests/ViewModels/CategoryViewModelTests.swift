import XCTest
@testable import ProductsApp

@MainActor
final class CategoryViewModelTests: XCTestCase {
    func testPreservesTopRatedAndAdditionalSections() async {
        let category = CategoryProducts(
            category: "electronics",
            topRated: [.fixture(id: 4), .fixture(id: 2)],
            additional: [.fixture(id: 9)]
        )
        let viewModel = CategoryViewModel(
            category: "electronics",
            repository: MockCatalogueRepository(category: .success(category))
        )

        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.state, .loaded(category))
    }

    func testEmptyCategoryUsesEmptyState() async {
        let viewModel = CategoryViewModel(
            category: "electronics",
            repository: MockCatalogueRepository()
        )

        await viewModel.reload()

        XCTAssertEqual(viewModel.state, .empty)
    }
}

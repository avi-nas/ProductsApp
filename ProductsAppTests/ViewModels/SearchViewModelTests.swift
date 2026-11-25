import XCTest
@testable import ProductsApp

@MainActor
final class SearchViewModelTests: XCTestCase {
    func testDoesNotRequestUntilExplicitSearchAndTrimsQuery() async {
        let product = Product.fixture()
        let repository = MockCatalogueRepository(search: .success([product]))
        let viewModel = SearchViewModel(repository: repository)

        viewModel.query = "  backpack  "
        let initialQueries = await repository.recordedSearchQueries()
        XCTAssertEqual(initialQueries, [])
        await viewModel.search()

        let queries = await repository.recordedSearchQueries()
        XCTAssertEqual(queries, ["backpack"])
        XCTAssertEqual(viewModel.state, .results([product]))
    }

    func testSuccessfulEmptyResultUsesEmptyState() async {
        let viewModel = SearchViewModel(repository: MockCatalogueRepository())
        viewModel.query = "missing"

        await viewModel.search()

        XCTAssertEqual(viewModel.state, .empty)
    }

    func testShowsLoadingWhileRequestIsInFlight() async {
        let repository = MockCatalogueRepository(suspendsSearch: true)
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "backpack"
        let search = Task { await viewModel.search() }
        await repository.waitUntilSearchStarts()

        XCTAssertEqual(viewModel.state, .loading)

        await repository.resumeSearch()
        await search.value
        XCTAssertEqual(viewModel.state, .empty)
    }

    func testFailureAndRetryRepeatLastSubmittedQuery() async {
        let repository = MockCatalogueRepository(search: .failure(.unavailable))
        let viewModel = SearchViewModel(repository: repository)
        viewModel.query = "jacket"

        await viewModel.search()
        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }
        viewModel.query = "changed but not submitted"
        await viewModel.retry()

        let queries = await repository.recordedSearchQueries()
        XCTAssertEqual(queries, ["jacket", "jacket"])
    }
}

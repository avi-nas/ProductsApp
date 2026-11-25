import Foundation
@testable import ProductsApp

enum RepositoryStubError: Error, LocalizedError, Sendable {
    case unavailable

    var errorDescription: String? {
        "Catalogue unavailable."
    }
}

enum StubResponse<Value: Sendable>: Sendable {
    case success(Value)
    case failure(RepositoryStubError)

    func value() throws -> Value {
        switch self {
        case let .success(value): return value
        case let .failure(error): throw error
        }
    }
}

actor MockCatalogueRepository: CatalogueRepository {
    let homeResponse: StubResponse<[Product]>
    let categoriesResponse: StubResponse<[String]>
    let categoryResponse: StubResponse<CategoryProducts>
    let searchResponse: StubResponse<[Product]>
    let productResponse: StubResponse<Product>
    private let suspendsSearch: Bool
    private var searchContinuation: CheckedContinuation<Void, Never>?

    private(set) var homeCallCount = 0
    private(set) var categoriesCallCount = 0
    private(set) var categoryCallCount = 0
    private(set) var searchQueries: [String] = []
    private(set) var productIDs: [Int] = []

    init(
        home: StubResponse<[Product]> = .success([]),
        categories: StubResponse<[String]> = .success([]),
        category: StubResponse<CategoryProducts> = .success(
            CategoryProducts(category: "electronics", topRated: [], additional: [])
        ),
        search: StubResponse<[Product]> = .success([]),
        product: StubResponse<Product> = .success(.fixture()),
        suspendsSearch: Bool = false
    ) {
        homeResponse = home
        categoriesResponse = categories
        categoryResponse = category
        searchResponse = search
        productResponse = product
        self.suspendsSearch = suspendsSearch
    }

    func home() async throws -> [Product] {
        homeCallCount += 1
        return try homeResponse.value()
    }

    func categories() async throws -> [String] {
        categoriesCallCount += 1
        return try categoriesResponse.value()
    }

    func category(_ category: String) async throws -> CategoryProducts {
        categoryCallCount += 1
        return try categoryResponse.value()
    }

    func search(_ query: String) async throws -> [Product] {
        searchQueries.append(query)
        if suspendsSearch {
            await withCheckedContinuation { searchContinuation = $0 }
        }
        return try searchResponse.value()
    }

    func product(id: Int) async throws -> Product {
        productIDs.append(id)
        return try productResponse.value()
    }

    func recordedSearchQueries() -> [String] { searchQueries }
    func recordedProductIDs() -> [Int] { productIDs }

    func waitUntilSearchStarts() async {
        while searchQueries.isEmpty {
            await Task.yield()
        }
    }

    func resumeSearch() {
        searchContinuation?.resume()
        searchContinuation = nil
    }
}

actor MockEnquiryRepository: EnquiryRepository {
    private let error: EnquirySubmissionError?
    private let suspends: Bool
    private var continuation: CheckedContinuation<Void, Never>?
    private(set) var submissions: [EnquirySubmission] = []

    init(error: EnquirySubmissionError? = nil, suspends: Bool = false) {
        self.error = error
        self.suspends = suspends
    }

    func submit(_ enquiry: EnquirySubmission) async throws {
        submissions.append(enquiry)
        if suspends {
            await withCheckedContinuation { continuation = $0 }
        }
        if let error { throw error }
    }

    func waitUntilSubmitted() async {
        while submissions.isEmpty {
            await Task.yield()
        }
    }

    func resume() {
        continuation?.resume()
        continuation = nil
    }

    func recordedSubmissions() -> [EnquirySubmission] { submissions }
}

extension Product {
    static func fixture(
        id: Int = 1,
        title: String = "Backpack",
        rating: Rating? = Rating(rate: 4.2, count: 40)
    ) -> Product {
        Product(
            id: id,
            title: title,
            price: 49.99,
            description: "A useful product.",
            category: "electronics",
            imageURL: URL(string: "https://example.test/product.png") ?? URL(fileURLWithPath: "/"),
            rating: rating
        )
    }
}

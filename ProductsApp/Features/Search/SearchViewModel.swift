import Combine
import Foundation

enum SearchState: Equatable {
    case idle
    case loading
    case results([Product])
    case empty
    case error(String)
}

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var state: SearchState = .idle

    var canSearch: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && state != .loading
    }

    private let repository: any CatalogueRepository
    private var lastSubmittedQuery: String?
    private var requestID = UUID()

    init(repository: any CatalogueRepository) {
        self.repository = repository
    }

    func search() async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        query = trimmedQuery
        lastSubmittedQuery = trimmedQuery
        await performSearch(trimmedQuery)
    }

    func retry() async {
        guard let lastSubmittedQuery else { return }
        await performSearch(lastSubmittedQuery)
    }

    private func performSearch(_ query: String) async {
        let currentRequest = UUID()
        requestID = currentRequest
        state = .loading
        do {
            let products = try await repository.search(query)
            guard requestID == currentRequest else { return }
            state = products.isEmpty ? .empty : .results(products)
        } catch is CancellationError {
            return
        } catch {
            guard requestID == currentRequest else { return }
            state = .error(userFacingMessage(for: error))
        }
    }
}

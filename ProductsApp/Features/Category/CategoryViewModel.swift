import Combine
import Foundation

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published private(set) var state: LoadState<CategoryProducts> = .idle

    let category: String
    private let repository: any CatalogueRepository
    private var requestID = UUID()

    init(category: String, repository: any CatalogueRepository) {
        self.category = category
        self.repository = repository
    }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await reload()
    }

    func reload() async {
        let currentRequest = UUID()
        requestID = currentRequest
        state = .loading
        do {
            let products = try await repository.category(category)
            guard requestID == currentRequest else { return }
            state = products.topRated.isEmpty && products.additional.isEmpty ? .empty : .loaded(products)
        } catch is CancellationError {
            return
        } catch {
            guard requestID == currentRequest else { return }
            state = .error(userFacingMessage(for: error))
        }
    }
}

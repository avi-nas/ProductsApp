import Combine
import Foundation

struct HomeContent: Equatable {
    let featuredProducts: [Product]
    let categories: [String]
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var state: LoadState<HomeContent> = .idle

    private let repository: any CatalogueRepository
    private var requestID = UUID()

    init(repository: any CatalogueRepository) {
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
            async let featuredProducts = repository.home()
            async let categories = repository.categories()
            let content = try await HomeContent(
                featuredProducts: featuredProducts,
                categories: categories
            )
            guard requestID == currentRequest else { return }
            state = content.featuredProducts.isEmpty ? .empty : .loaded(content)
        } catch is CancellationError {
            return
        } catch {
            guard requestID == currentRequest else { return }
            state = .error(userFacingMessage(for: error))
        }
    }
}

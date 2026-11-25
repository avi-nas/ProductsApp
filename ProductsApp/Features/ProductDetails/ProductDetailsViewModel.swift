import Combine
import Foundation

@MainActor
final class ProductDetailsViewModel: ObservableObject {
    @Published private(set) var state: LoadState<Product> = .idle

    let productID: Int
    private let repository: any CatalogueRepository
    private var requestID = UUID()

    init(productID: Int, repository: any CatalogueRepository) {
        self.productID = productID
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
            let product = try await repository.product(id: productID)
            guard requestID == currentRequest else { return }
            state = .loaded(product)
        } catch is CancellationError {
            return
        } catch {
            guard requestID == currentRequest else { return }
            state = .error(userFacingMessage(for: error))
        }
    }
}

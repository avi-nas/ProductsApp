import Foundation

struct LiveCatalogueRepository: CatalogueRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func home() async throws -> [Product] {
        let envelope: APIEnvelopeDTO<HomeDTO> = try await apiClient.get(
            path: ["api", "v1", "home"]
        )
        return envelope.data.featuredProducts.map { $0.toDomain() }
    }

    func categories() async throws -> [String] {
        let envelope: APIEnvelopeDTO<[String]> = try await apiClient.get(
            path: ["api", "v1", "categories"]
        )
        return envelope.data
    }

    func category(_ category: String) async throws -> CategoryProducts {
        let envelope: APIEnvelopeDTO<CategoryProductsDTO> = try await apiClient.get(
            path: ["api", "v1", "categories", category, "products"]
        )
        return envelope.data.toDomain()
    }

    func search(_ query: String) async throws -> [Product] {
        let envelope: APIEnvelopeDTO<[ProductDTO]> = try await apiClient.get(
            path: ["api", "v1", "products", "search"],
            queryItems: [URLQueryItem(name: "q", value: query)]
        )
        return envelope.data.map { $0.toDomain() }
    }

    func product(id: Int) async throws -> Product {
        let envelope: APIEnvelopeDTO<ProductDTO> = try await apiClient.get(
            path: ["api", "v1", "products", String(id)]
        )
        return envelope.data.toDomain()
    }
}

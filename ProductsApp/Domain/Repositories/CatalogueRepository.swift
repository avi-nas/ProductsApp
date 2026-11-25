protocol CatalogueRepository: Sendable {
    func home() async throws -> [Product]
    func categories() async throws -> [String]
    func category(_ category: String) async throws -> CategoryProducts
    func search(_ query: String) async throws -> [Product]
    func product(id: Int) async throws -> Product
}

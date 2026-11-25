struct CategoryProductsDTO: Decodable {
    let category: String
    let topRated: [ProductDTO]
    let additional: [ProductDTO]

    func toDomain() -> CategoryProducts {
        CategoryProducts(
            category: category,
            topRated: topRated.map { $0.toDomain() },
            additional: additional.map { $0.toDomain() }
        )
    }
}

struct CategoryProducts: Equatable, Sendable {
    let category: String
    let topRated: [Product]
    let additional: [Product]
}

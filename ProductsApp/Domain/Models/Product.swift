import Foundation

struct Rating: Hashable, Sendable {
    let rate: Double
    let count: Int
}

struct Product: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let imageURL: URL
    let rating: Rating?
}

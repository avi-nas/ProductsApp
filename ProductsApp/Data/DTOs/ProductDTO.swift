import Foundation

struct RatingDTO: Decodable {
    let rate: Double
    let count: Int

    func toDomain() -> Rating {
        Rating(rate: rate, count: count)
    }
}

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let imageUrl: URL
    let rating: RatingDTO?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case price
        case description
        case category
        case imageUrl
        case rating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard container.contains(.rating) else {
            throw DecodingError.keyNotFound(
                CodingKeys.rating,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "The required rating key is missing."
                )
            )
        }

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(Double.self, forKey: .price)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        rating = try container.decodeIfPresent(RatingDTO.self, forKey: .rating)
    }

    func toDomain() -> Product {
        Product(
            id: id,
            title: title,
            price: price,
            description: description,
            category: category,
            imageURL: imageUrl,
            rating: rating?.toDomain()
        )
    }
}

struct HomeDTO: Decodable {
    let featuredProducts: [ProductDTO]
}

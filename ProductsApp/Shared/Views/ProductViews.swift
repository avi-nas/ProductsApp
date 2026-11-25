import SwiftUI

struct ProductImage: View {
    let url: URL
    var height: CGFloat = 180

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(16)
                    .transition(.opacity)
            case .failure:
                placeholder(systemImage: "photo.badge.exclamationmark")
            case .empty:
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
            @unknown default:
                placeholder(systemImage: "photo")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityLabel("Product image")
    }

    private func placeholder(systemImage: String) -> some View {
        ZStack {
            Color(.secondarySystemBackground)
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
        }
    }
}

struct RatingView: View {
    let rating: Rating?

    var body: some View {
        if let rating {
            Label {
                Text("\(rating.rate, specifier: "%.1f") · \(rating.count) reviews")
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .accessibilityLabel("Rated \(rating.rate, specifier: "%.1f") out of 5 from \(rating.count) reviews")
        } else {
            Label("Not rated", systemImage: "star")
                .foregroundStyle(.secondary)
        }
    }
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProductImage(url: product.imageURL, height: 160)
            Text(product.category.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tint)
                .lineLimit(1)
            Text(product.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .firstTextBaseline) {
                Text(product.price, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                Spacer()
                if let rating = product.rating {
                    Label("\(rating.rate, specifier: "%.1f")", systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.title), \(product.price.formatted(.currency(code: "USD")))")
        .accessibilityIdentifier("productCard_\(product.id)")
    }
}

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            ProductImage(url: product.imageURL, height: 104)
                .frame(width: 104)
            VStack(alignment: .leading, spacing: 7) {
                Text(product.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                RatingView(rating: product.rating)
                    .font(.caption)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.title), \(product.price.formatted(.currency(code: "USD")))")
        .accessibilityIdentifier("productRow_\(product.id)")
    }
}

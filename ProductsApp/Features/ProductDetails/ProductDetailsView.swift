import SwiftUI

struct ProductDetailsView: View {
    @StateObject private var viewModel: ProductDetailsViewModel
    let showEnquiry: (Int) -> Void

    init(
        productID: Int,
        repository: any CatalogueRepository,
        showEnquiry: @escaping (Int) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: ProductDetailsViewModel(productID: productID, repository: repository)
        )
        self.showEnquiry = showEnquiry
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingStateView("Loading product details…")
            case let .loaded(product):
                details(product)
            case .empty:
                EmptyStateView(
                    title: "Product Unavailable",
                    message: "This product is no longer available.",
                    systemImage: "shippingbox"
                )
            case let .error(message):
                ErrorStateView(message: message) {
                    Task { await viewModel.reload() }
                }
            }
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadIfNeeded() }
    }

    private func details(_ product: Product) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ProductImage(url: product.imageURL, height: 320)
                VStack(alignment: .leading, spacing: 10) {
                    Text(product.category.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tint)
                    Text(product.title)
                        .font(.largeTitle.bold())
                        .fixedSize(horizontal: false, vertical: true)
                    Text(product.price, format: .currency(code: "USD"))
                        .font(.title2.bold())
                    RatingView(rating: product.rating)
                        .font(.subheadline)
                }
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this product")
                        .font(.title3.bold())
                    Text(product.description.isEmpty ? "No description available." : product.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button {
                    showEnquiry(product.id)
                } label: {
                    Label("Enquire about this product", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("enquiryButton")
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .refreshable { await viewModel.reload() }
    }
}

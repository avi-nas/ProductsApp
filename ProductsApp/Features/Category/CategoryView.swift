import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel: CategoryViewModel
    let showProduct: (Int) -> Void

    init(
        category: String,
        repository: any CatalogueRepository,
        showProduct: @escaping (Int) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: CategoryViewModel(category: category, repository: repository)
        )
        self.showProduct = showProduct
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingStateView()
            case let .loaded(products):
                productList(products)
            case .empty:
                EmptyStateView(
                    title: "No Products",
                    message: "There are no products in this category.",
                    systemImage: "shippingbox"
                )
            case let .error(message):
                ErrorStateView(message: message) {
                    Task { await viewModel.reload() }
                }
            }
        }
        .navigationTitle(viewModel.category.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadIfNeeded() }
    }

    private func productList(_ products: CategoryProducts) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                productSection(
                    title: "Top rated",
                    subtitle: "The two highest-ranked products in this category.",
                    products: products.topRated
                )
                if !products.additional.isEmpty {
                    productSection(
                        title: "More to explore",
                        subtitle: nil,
                        products: products.additional
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .refreshable { await viewModel.reload() }
    }

    private func productSection(title: String, subtitle: String?, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HorizontalSizeClassLayout {
                LazyVStack(spacing: 12) {
                    ForEach(products) { product in
                        productButton(product) {
                            ProductRow(product: product)
                        }
                    }
                }
            } regular: {
                LazyVGrid(columns: regularColumns, spacing: 12) {
                    ForEach(products) { product in
                        productButton(product) {
                            ProductCard(product: product)
                        }
                    }
                }
            }
        }
    }

    private var regularColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16, alignment: .top), count: 2)
    }

    private func productButton<Label: View>(
        _ product: Product,
        @ViewBuilder label: () -> Label
    ) -> some View {
        Button {
            showProduct(product.id)
        } label: {
            label()
        }
        .buttonStyle(.plain)
    }
}

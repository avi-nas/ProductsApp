import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    let showCategory: (String) -> Void
    let showProduct: (Int) -> Void
    let showSearch: () -> Void

    init(
        repository: any CatalogueRepository,
        showCategory: @escaping (String) -> Void,
        showProduct: @escaping (Int) -> Void,
        showSearch: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
        self.showCategory = showCategory
        self.showProduct = showProduct
        self.showSearch = showSearch
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingStateView("Curating today’s products…")
            case let .loaded(content):
                contentView(content)
            case .empty:
                EmptyStateView(
                    title: "No Products Yet",
                    message: "The catalogue is currently empty. Please try again shortly.",
                    systemImage: "shippingbox"
                )
            case let .error(message):
                ErrorStateView(message: message) {
                    Task { await viewModel.reload() }
                }
            }
        }
        .navigationTitle("Discover")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: showSearch) {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel("Search products")
                .accessibilityIdentifier("searchNavigationButton")
            }
        }
        .task { await viewModel.loadIfNeeded() }
    }

    private func contentView(_ content: HomeContent) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Find something special")
                        .font(.largeTitle.bold())
                    Text("A hand-picked selection from across the catalogue.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if !content.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("Shop by category")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(content.categories, id: \.self) { category in
                                    Button(category.capitalized) {
                                        showCategory(category)
                                    }
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.capsule)
                                    .accessibilityIdentifier("category_\(category)")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("Featured")
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 14) {
                            ForEach(content.featuredProducts) { product in
                                Button {
                                    showProduct(product.id)
                                } label: {
                                    ProductCard(product: product)
                                        .frame(width: 245)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .refreshable { await viewModel.reload() }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title2.bold())
            .padding(.horizontal)
    }
}

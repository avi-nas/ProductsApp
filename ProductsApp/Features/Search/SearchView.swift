import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    let showProduct: (Int) -> Void

    init(repository: any CatalogueRepository, showProduct: @escaping (Int) -> Void) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(repository: repository))
        self.showProduct = showProduct
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Group {
                switch viewModel.state {
                case .idle:
                    EmptyStateView(
                        title: "Search the Catalogue",
                        message: "Enter a product title or description, then tap Search.",
                        systemImage: "magnifyingglass"
                    )
                case .loading:
                    LoadingStateView("Searching products…")
                case let .results(products):
                    results(products)
                case .empty:
                    EmptyStateView(
                        title: "No Products Found",
                        message: "Try a different title or description.",
                        systemImage: "magnifyingglass"
                    )
                case let .error(message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.retry() }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                TextField("Title or description", text: $viewModel.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .focused($isSearchFocused)
                    .onSubmit { submit() }
                    .accessibilityIdentifier("searchField")
                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))

            Button("Search", action: submit)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSearch)
                .accessibilityIdentifier("searchButton")
        }
        .padding()
        .background(.bar)
    }

    private func results(_ products: [Product]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(products) { product in
                    Button {
                        showProduct(product.id)
                    } label: {
                        ProductRow(product: product)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private func submit() {
        guard viewModel.canSearch else { return }
        isSearchFocused = false
        Task { await viewModel.search() }
    }
}

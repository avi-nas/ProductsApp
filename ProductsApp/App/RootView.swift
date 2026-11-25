import SwiftUI

struct RootView: View {
    let dependencies: DependencyContainer
    @State private var path: [AppRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                repository: dependencies.catalogueRepository,
                showCategory: { path.append(.category($0)) },
                showProduct: { path.append(.product($0)) },
                showSearch: { path.append(.search) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .search:
            SearchView(
                repository: dependencies.catalogueRepository,
                showProduct: { path.append(.product($0)) }
            )
        case let .category(category):
            CategoryView(
                category: category,
                repository: dependencies.catalogueRepository,
                showProduct: { path.append(.product($0)) }
            )
        case let .product(productID):
            ProductDetailsView(
                productID: productID,
                repository: dependencies.catalogueRepository,
                showEnquiry: { path.append(.enquiry($0)) }
            )
        case let .enquiry(productID):
            EnquiryView(
                productID: productID,
                repository: dependencies.enquiryRepository,
                didSubmit: { path.append(.thankYou) }
            )
        case .thankYou:
            ThankYouView { path.removeAll() }
        }
    }
}

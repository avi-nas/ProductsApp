import SwiftUI

struct RootView: View {
    let dependencies: DependencyContainer

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 44))
                    .accessibilityHidden(true)
                Text("ProductsApp")
                    .font(.title.bold())
                Text("Phase 1 data foundation is ready.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Products")
        }
    }
}

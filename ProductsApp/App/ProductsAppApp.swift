import SwiftUI

@main
struct ProductsAppApp: App {
    private let dependencies: DependencyContainer

    init() {
        do {
            dependencies = try .live()
        } catch {
            preconditionFailure("ProductsApp configuration failed: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}

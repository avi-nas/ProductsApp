import Foundation

struct DependencyContainer {
    let catalogueRepository: any CatalogueRepository
    let enquiryRepository: any EnquiryRepository

    static func live(bundle: Bundle = .main) throws -> DependencyContainer {
        let configuration = try AppConfiguration.live(bundle: bundle)
        let httpClient = URLSessionHTTPClient(session: .shared)
        let apiClient = APIClient(baseURL: configuration.apiBaseURL, httpClient: httpClient)

        return DependencyContainer(
            catalogueRepository: LiveCatalogueRepository(apiClient: apiClient),
            enquiryRepository: LiveEnquiryRepository(apiClient: apiClient)
        )
    }
}

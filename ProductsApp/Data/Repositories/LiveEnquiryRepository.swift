struct LiveEnquiryRepository: EnquiryRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func submit(_ enquiry: EnquirySubmission) async throws {
        let envelope: APIEnvelopeDTO<EnquiryResponseDTO> = try await apiClient.post(
            path: ["api", "v1", "enquiries"],
            body: EnquiryRequestDTO(enquiry: enquiry)
        )
        guard envelope.data.submitted else {
            throw APIError.invalidResponse
        }
    }
}

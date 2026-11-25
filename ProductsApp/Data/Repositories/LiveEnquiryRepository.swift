struct LiveEnquiryRepository: EnquiryRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func submit(_ enquiry: EnquirySubmission) async throws {
        do {
            let envelope: APIEnvelopeDTO<EnquiryResponseDTO> = try await apiClient.post(
                path: ["api", "v1", "enquiries"],
                body: EnquiryRequestDTO(enquiry: enquiry)
            )
            guard envelope.data.submitted else {
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            guard case let .server(_, _, message, details) = error else {
                throw error
            }
            throw EnquirySubmissionError(
                message: message,
                fieldErrors: Self.mapFieldErrors(details)
            )
        }
    }

    private static func mapFieldErrors(
        _ details: [String: [String]]?
    ) -> [EnquiryField: String] {
        guard let details else { return [:] }
        var fieldErrors: [EnquiryField: String] = [:]
        if let message = details["name"]?.first { fieldErrors[.name] = message }
        if let message = details["email"]?.first { fieldErrors[.email] = message }
        if let message = details["message"]?.first { fieldErrors[.message] = message }
        return fieldErrors
    }
}

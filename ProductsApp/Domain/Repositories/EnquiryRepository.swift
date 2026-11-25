protocol EnquiryRepository: Sendable {
    func submit(_ enquiry: EnquirySubmission) async throws
}

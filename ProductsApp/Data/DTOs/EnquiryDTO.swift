struct EnquiryRequestDTO: Encodable, Sendable {
    let name: String
    let email: String
    let productId: Int
    let message: String?

    init(enquiry: EnquirySubmission) {
        name = enquiry.name
        email = enquiry.email
        productId = enquiry.productID
        message = enquiry.message
    }
}

struct EnquiryResponseDTO: Decodable {
    let submitted: Bool
}

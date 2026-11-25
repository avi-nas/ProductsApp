import Foundation

struct EnquirySubmission: Equatable, Sendable {
    let name: String
    let email: String
    let productID: Int
    let message: String?
}

enum EnquiryField: Hashable, Sendable {
    case name
    case email
    case message
}

struct EnquirySubmissionError: Error, Equatable, LocalizedError, Sendable {
    let message: String
    let fieldErrors: [EnquiryField: String]

    var errorDescription: String? {
        message
    }
}

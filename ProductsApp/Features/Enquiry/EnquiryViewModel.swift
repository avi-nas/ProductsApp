import Combine
import Foundation

enum EnquiryState: Equatable {
    case idle
    case submitting
    case failed(String)
    case submitted
}

@MainActor
final class EnquiryViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var message = ""
    @Published private(set) var fieldErrors: [EnquiryField: String] = [:]
    @Published private(set) var state: EnquiryState = .idle

    let productID: Int
    private let repository: any EnquiryRepository

    init(productID: Int, repository: any EnquiryRepository) {
        self.productID = productID
        self.repository = repository
    }

    var isSubmitting: Bool {
        state == .submitting
    }

    @discardableResult
    func submit() async -> Bool {
        guard !isSubmitting else { return false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        fieldErrors = validate(name: trimmedName, email: trimmedEmail, rawMessage: message)
        guard fieldErrors.isEmpty else {
            state = .failed("Please correct the highlighted fields.")
            return false
        }

        name = trimmedName
        email = trimmedEmail
        message = trimmedMessage
        state = .submitting

        do {
            try await repository.submit(
                EnquirySubmission(
                    name: trimmedName,
                    email: trimmedEmail,
                    productID: productID,
                    message: trimmedMessage.isEmpty ? nil : trimmedMessage
                )
            )
            state = .submitted
            return true
        } catch is CancellationError {
            state = .idle
            return false
        } catch {
            applyBackendFieldErrors(from: error)
            state = .failed(userFacingMessage(for: error))
            return false
        }
    }

    private func validate(name: String, email: String, rawMessage: String) -> [EnquiryField: String] {
        var errors: [EnquiryField: String] = [:]
        if name.isEmpty || name.count > 100 {
            errors[.name] = "Enter a name between 1 and 100 characters."
        }
        if !Self.isValidEmail(email) {
            errors[.email] = "Enter a valid email address."
        }
        if rawMessage.count > 2_000 {
            errors[.message] = "Message must be 2,000 characters or fewer."
        }
        return errors
    }

    private static func isValidEmail(_ email: String) -> Bool {
        guard email.count <= 254, !email.contains(where: { $0.isWhitespace }) else { return false }
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let domainParts = parts[1].split(separator: ".", omittingEmptySubsequences: false)
        return domainParts.count >= 2 && domainParts.allSatisfy { !$0.isEmpty }
    }

    private func applyBackendFieldErrors(from error: Error) {
        guard let error = error as? EnquirySubmissionError else { return }
        fieldErrors.merge(error.fieldErrors) { _, backendMessage in backendMessage }
    }
}

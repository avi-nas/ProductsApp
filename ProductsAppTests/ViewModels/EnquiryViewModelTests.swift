import XCTest
@testable import ProductsApp

@MainActor
final class EnquiryViewModelTests: XCTestCase {
    func testLocalValidationPreventsSubmission() async {
        let repository = MockEnquiryRepository()
        let viewModel = EnquiryViewModel(productID: 1, repository: repository)
        viewModel.name = ""
        viewModel.email = "invalid"

        let submitted = await viewModel.submit()

        XCTAssertFalse(submitted)
        XCTAssertNotNil(viewModel.fieldErrors[.name])
        XCTAssertNotNil(viewModel.fieldErrors[.email])
        let submissions = await repository.recordedSubmissions()
        XCTAssertEqual(submissions, [])
    }

    func testSuccessfulSubmissionTrimsValuesAndReachesSubmittedState() async {
        let repository = MockEnquiryRepository()
        let viewModel = EnquiryViewModel(productID: 3, repository: repository)
        viewModel.name = "  Asha Patel  "
        viewModel.email = "  asha@example.test  "
        viewModel.message = "  Please call me.  "

        let submitted = await viewModel.submit()

        XCTAssertTrue(submitted)
        XCTAssertEqual(viewModel.state, .submitted)
        let submissions = await repository.recordedSubmissions()
        XCTAssertEqual(
            submissions,
            [EnquirySubmission(name: "Asha Patel", email: "asha@example.test", productID: 3, message: "Please call me.")]
        )
    }

    func testDuplicateSubmissionIsBlockedWhileFirstIsInFlight() async {
        let repository = MockEnquiryRepository(suspends: true)
        let viewModel = validViewModel(repository: repository)
        let firstSubmission = Task { await viewModel.submit() }
        await repository.waitUntilSubmitted()

        let duplicateResult = await viewModel.submit()
        XCTAssertFalse(duplicateResult)
        let submissionCount = await repository.recordedSubmissions().count
        XCTAssertEqual(submissionCount, 1)

        await repository.resume()
        let firstResult = await firstSubmission.value
        XCTAssertTrue(firstResult)
    }

    func testBackendFieldErrorsRemainEditableAndDoNotSucceed() async {
        let error = EnquirySubmissionError(
            message: "The request is invalid.",
            fieldErrors: [.email: "Email is not accepted."]
        )
        let viewModel = validViewModel(repository: MockEnquiryRepository(error: error))

        let submitted = await viewModel.submit()

        XCTAssertFalse(submitted)
        XCTAssertEqual(viewModel.state, .failed("The request is invalid."))
        XCTAssertEqual(viewModel.fieldErrors[.email], "Email is not accepted.")
    }

    private func validViewModel(repository: MockEnquiryRepository) -> EnquiryViewModel {
        let viewModel = EnquiryViewModel(productID: 1, repository: repository)
        viewModel.name = "Asha"
        viewModel.email = "asha@example.test"
        return viewModel
    }
}

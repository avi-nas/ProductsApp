import SwiftUI

struct EnquiryView: View {
    @StateObject private var viewModel: EnquiryViewModel
    let didSubmit: () -> Void

    init(
        productID: Int,
        repository: any EnquiryRepository,
        didSubmit: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EnquiryViewModel(productID: productID, repository: repository)
        )
        self.didSubmit = didSubmit
    }

    var body: some View {
        Form {
            Section {
                Label("Product #\(viewModel.productID)", systemImage: "shippingbox")
                    .foregroundStyle(.secondary)
            } header: {
                Text("Product")
            } footer: {
                Text("Our sales team will receive the selected product details with your enquiry.")
            }

            Section("Your details") {
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.name)
                        .accessibilityIdentifier("enquiryNameField")
                    fieldError(.name)
                }
                VStack(alignment: .leading, spacing: 5) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("enquiryEmailField")
                    fieldError(.email)
                }
            }

            Section {
                TextEditor(text: $viewModel.message)
                    .frame(minHeight: 120)
                    .accessibilityLabel("Optional message")
                    .accessibilityIdentifier("enquiryMessageField")
                HStack {
                    fieldError(.message)
                    Spacer()
                    Text("\(viewModel.message.count)/2000")
                        .font(.caption)
                        .foregroundStyle(viewModel.message.count > 2_000 ? .red : .secondary)
                }
            } header: {
                Text("Message (optional)")
            }

            if case let .failed(message) = viewModel.state {
                Section {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("enquiryError")
                }
            }

            Section {
                Button(action: submit) {
                    HStack {
                        Spacer()
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Send enquiry", systemImage: "paperplane.fill")
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isSubmitting)
                .accessibilityIdentifier("submitEnquiryButton")
            }
        }
        .disabled(viewModel.isSubmitting)
        .navigationTitle("Product Enquiry")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isSubmitting)
        .scrollDismissesKeyboard(.interactively)
    }

    @ViewBuilder
    private func fieldError(_ field: EnquiryField) -> some View {
        if let error = viewModel.fieldErrors[field] {
            Text(error)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }

    private func submit() {
        Task {
            if await viewModel.submit() {
                didSubmit()
            }
        }
    }
}

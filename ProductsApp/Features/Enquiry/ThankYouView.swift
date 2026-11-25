import SwiftUI

struct ThankYouView: View {
    let returnHome: () -> Void

    var body: some View {
        HorizontalSizeClassLayout {
            VStack(spacing: 22) {
                confirmationIcon
                confirmationContent
            }
        } regular: {
            HStack(spacing: 32) {
                confirmationIcon
                confirmationContent
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
    }

    private var confirmationIcon: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.14))
                .frame(width: 104, height: 104)
            Image(systemName: "checkmark")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.green)
        }
        .accessibilityHidden(true)
    }

    private var confirmationContent: some View {
        VStack(spacing: 22) {
            VStack(spacing: 10) {
                Text("Thank you")
                    .font(.largeTitle.bold())
                Text("Your enquiry has been sent. Our sales team will contact you using the email address provided.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: returnHome) {
                Label("Return to Home", systemImage: "house.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("returnHomeButton")
        }
        .frame(maxWidth: 520)
    }
}

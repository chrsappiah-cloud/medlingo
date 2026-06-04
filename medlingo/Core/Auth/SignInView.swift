import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    // Header
                    VStack(spacing: AppSpacing.sm) {
                        Text("Medlingo")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColor.gold, AppColor.diamond, AppColor.gold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text("Sign in to your account")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColor.textSecondary)
                    }
                    .padding(.top, AppSpacing.xxl)

                    // Email / Password form
                    VStack(spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Email")
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColor.textSecondary)
                            TextField("you@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(AppSpacing.md)
                                .background(AppColor.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.md)
                                        .stroke(AppColor.diamond.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundColor(AppColor.textPrimary)
                                .accessibilityIdentifier("sign-in-email-field")
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Password")
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColor.textSecondary)
                            SecureField("••••••••", text: $password)
                                .textContentType(.password)
                                .padding(AppSpacing.md)
                                .background(AppColor.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.md)
                                        .stroke(AppColor.diamond.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundColor(AppColor.textPrimary)
                                .accessibilityIdentifier("sign-in-password-field")
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(AppTypography.caption1)
                                .foregroundColor(AppColor.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityIdentifier("sign-in-error-label")
                        }

                        PrimaryButton(title: "Sign In", isLoading: isLoading) {
                            signInWithEmail()
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .accessibilityIdentifier("sign-in-button")
                    }

                    // Divider
                    HStack {
                        Rectangle().fill(AppColor.diamond.opacity(0.15)).frame(height: 1)
                        Text("or")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColor.textTertiary)
                            .padding(.horizontal, AppSpacing.sm)
                        Rectangle().fill(AppColor.diamond.opacity(0.15)).frame(height: 1)
                    }

                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    .accessibilityIdentifier("sign-in-apple-button")

                    Spacer(minLength: AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .background(AppColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColor.diamond)
                        .accessibilityIdentifier("sign-in-cancel-button")
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Actions

    private func signInWithEmail() {
        guard !email.isEmpty, !password.isEmpty else { return }
        errorMessage = nil
        isLoading = true
        Task {
            do {
                try await appState.authService.signInWithEmail(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Invalid Apple credential."
                return
            }
            errorMessage = nil
            isLoading = true
            Task {
                do {
                    try await appState.authService.signInWithApple(credential: credential)
                    dismiss()
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        case .failure(let error):
            // Cancelled by user — don't show an error
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AppState.shared)
}

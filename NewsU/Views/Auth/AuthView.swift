import SwiftUI

struct AuthView: View {
    @EnvironmentObject var appState: AppState

    enum Mode { case signIn, signUp }

    @State private var mode: Mode = .signUp
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var isFormValid: Bool {
        let emailOK = email.contains("@") && email.contains(".")
        let passwordOK = password.count >= 6
        let nameOK = mode == .signIn || !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        return emailOK && passwordOK && nameOK
    }

    var body: some View {
        ZStack {
            NewsUTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 14) {
                        AppMarkBadge(size: 76)
                        Text("NewsU")
                            .font(.newsUWordmark(38))
                            .tracking(0.5)
                            .foregroundStyle(NewsUTheme.ink)
                        Text(mode == .signUp ? "Create your account to get started." : "Welcome back.")
                            .font(.newsUBody)
                            .foregroundStyle(NewsUTheme.inkSecondary)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 14) {
                        if mode == .signUp {
                            NewsUTextField(title: "Name", text: $displayName, textContentType: .name)
                        }
                        NewsUTextField(title: "Email", text: $email, keyboard: .emailAddress, textContentType: .emailAddress)
                        NewsUTextField(title: "Password", text: $password, isSecure: true, textContentType: mode == .signUp ? .newPassword : .password)
                    }
                    .padding(20)
                    .newsUCard()

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.newsUCaption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 14) {
                        PrimaryButton(
                            title: isSubmitting ? "Please wait…" : (mode == .signUp ? "Create Account" : "Sign In"),
                            isEnabled: isFormValid && !isSubmitting,
                            action: submit
                        )

                        Button {
                            withAnimation { mode = mode == .signUp ? .signIn : .signUp }
                            errorMessage = nil
                        } label: {
                            Text(mode == .signUp ? "Already have an account? Sign In" : "New here? Create an Account")
                                .font(.newsUCaption.weight(.medium))
                                .foregroundStyle(NewsUTheme.inkSecondary)
                        }
                    }

                    Text("By continuing you agree to NewsU's Terms of Use and Privacy Policy.")
                        .font(.caption2)
                        .foregroundStyle(NewsUTheme.inkFaint)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func submit() {
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                if mode == .signUp {
                    try await appState.signUp(email: email, password: password, displayName: displayName)
                } else {
                    try await appState.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}

struct NewsUTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1)
                .foregroundStyle(NewsUTheme.inkFaint)
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .textContentType(textContentType)
            .font(.newsUBody)
            .foregroundStyle(NewsUTheme.ink)
        }
    }
}

#Preview {
    AuthView().environmentObject(AppState())
}

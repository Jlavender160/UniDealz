import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var firestoreService: FirestoreService
    @Environment(\.dismiss) var dismiss

    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var displayName = ""

    private var hasMinLength:   Bool { password.count >= 12 }
    private var hasUppercase:   Bool { password.range(of: "[A-Z]", options: .regularExpression) != nil }
    private var hasLowercase:   Bool { password.range(of: "[a-z]", options: .regularExpression) != nil }
    private var hasNumber:      Bool { password.range(of: "[0-9]", options: .regularExpression) != nil }
    private var hasSpecial:     Bool { password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && password == confirmPassword }

    private var isPasswordValid: Bool {
        hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial
    }

    private var canRegister: Bool {
        !displayName.isEmpty && !email.isEmpty && isPasswordValid && passwordsMatch
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(AppColors.primary)

                VStack(spacing: 12) {
                    TextField("Display Name", text: $displayName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)

                    if !confirmPassword.isEmpty {
                        HStack {
                            Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(passwordsMatch ? .green : .red)
                            Text(passwordsMatch ? "Passwords match" : "Passwords do not match")
                                .font(.caption)
                                .foregroundColor(passwordsMatch ? .green : .red)
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)

                if !authService.errorMessage.isEmpty {
                    Text(authService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                Button(action: {
                    let e = email
                    let d = displayName
                    authService.register(email: e, password: password, displayName: d) {
                        firestoreService.createUserProfile(email: e, displayName: d)
                        Task { @MainActor in dismiss() }
                    }
                }) {
                    if authService.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Register")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .padding(.horizontal)
                .disabled(!canRegister || authService.isLoading)

                Button("Already have an account? Sign In") { dismiss() }
                    .foregroundColor(AppColors.primary)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.background.ignoresSafeArea())
            .colorScheme(.light)
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthService())
        .environmentObject(FirestoreService())
}

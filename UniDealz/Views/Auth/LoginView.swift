import SwiftUI

// TextField/SecureField layout, ProgressView loading pattern, and
// Auth.auth().signIn closure structure adapted from FirebaseLogin tutorial
//additional reference: testingapp by Johnson, Thomas (
struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State var email = ""
    @State var password = ""
    @State var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("UniDealz")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(AppColors.primary)

                Text("Nottingham Student Deals")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                if !authService.errorMessage.isEmpty {
                    Text(authService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                Button(action: {
                    authService.signIn(email: email, password: password)
                }) {
                    if authService.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Sign In")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
                .padding(.horizontal)
                .disabled(authService.isLoading)

                Button("Don't have an account? Register") {
                    showRegister = true
                }
                .foregroundColor(AppColors.primary)

                Spacer()
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .background(AppColors.background.ignoresSafeArea())
            .colorScheme(.light)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}

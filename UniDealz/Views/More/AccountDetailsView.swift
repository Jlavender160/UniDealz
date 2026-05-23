import SwiftUI

struct AccountDetailsView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @State var displayName = ""
    @State var email = ""
    @State var showSaved = false

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Display Name", text: $displayName)
                TextField("Email", text: $email)
                    .disabled(true)
                    .foregroundColor(AppColors.textSecondary)
            }

            Button("Save Changes") {
                if var profile = firestoreService.userProfile {
                    profile.displayName = displayName
                    firestoreService.updateUserProfile(profile)
                    showSaved = true
                }
            }
            .foregroundColor(AppColors.primary)
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Account Details")
        .onAppear {
            displayName = firestoreService.userProfile?.displayName ?? ""
            email = firestoreService.userProfile?.email ?? ""
        }
        .alert("Saved", isPresented: $showSaved) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    AccountDetailsView()
        .environmentObject(FirestoreService())
}

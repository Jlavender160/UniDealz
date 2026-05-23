import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var notificationService: NotificationService

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: AccountDetailsView()) {
                        Label("Account Details", systemImage: "person.circle")
                    }
                    NavigationLink(destination: ReviewsListView()) {
                        Label("My Reviews", systemImage: "star.bubble")
                    }
                }

                Section {
                    Toggle(isOn: Binding(
                        get: { firestoreService.userProfile?.notificationsEnabled ?? true },
                        set: { newValue in
                            if var profile = firestoreService.userProfile {
                                profile.notificationsEnabled = newValue
                                firestoreService.updateUserProfile(profile)
                            }
                            notificationService.scheduleDealNotifications(
                                deals: firestoreService.deals,
                                enabled: newValue
                            )
                        }
                    )) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authService.signOut()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("More")
            .tint(AppColors.primary)
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(AuthService())
        .environmentObject(FirestoreService())
        .environmentObject(NotificationService())
}

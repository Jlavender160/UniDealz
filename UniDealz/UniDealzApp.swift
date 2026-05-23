import SwiftUI
import Firebase
import GoogleMaps

//GMSServices.provideAPIKey setup in init() adapted from googlemaps tutorial
@main
struct UniDealzApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var firestoreService = FirestoreService()
    @StateObject private var locationService = LocationService()
    @StateObject private var notificationService = NotificationService()

    init() {
        FirebaseApp.configure()
        GMSServices.provideAPIKey(Config.googleMapsKey)
    }

    var body: some Scene {
        WindowGroup {
            if authService.isLoggedIn {
                ContentView()
                    .environmentObject(authService)
                    .environmentObject(firestoreService)
                    .environmentObject(locationService)
                    .environmentObject(notificationService)
                    .onAppear {
                        firestoreService.fetchDeals()
                        firestoreService.fetchVenues()
                        firestoreService.fetchUserProfile()
                        locationService.requestPermission()
                        notificationService.requestPermission()
                    }
                    .onChange(of: firestoreService.deals) { _, deals in
                        let enabled = firestoreService.userProfile?.notificationsEnabled ?? true
                        notificationService.scheduleDealNotifications(deals: deals, enabled: enabled)
                    }
                    .onChange(of: authService.isLoggedIn) { _, loggedIn in
                        if loggedIn {
                            firestoreService.fetchDeals()
                            firestoreService.fetchVenues()
                            firestoreService.fetchUserProfile()
                        } else {
                            firestoreService.clearUserData()
                        }
                    }
            } else {
                LoginView()
                    .environmentObject(authService)
                    .environmentObject(firestoreService)
            }
        }
    }
}

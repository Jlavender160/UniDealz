import SwiftUI

struct ContentView: View {
    var body: some View {
        // tabview structure
        // adapted from BottomNavigation tutorial
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            MapTabView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            LikesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Likes")
                }
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("More")
                }
        }
        .tint(AppColors.primary)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
        .environmentObject(FirestoreService())
        .environmentObject(LocationService())
        .environmentObject(NotificationService())
}

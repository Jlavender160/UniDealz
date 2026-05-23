import SwiftUI

struct MapTabView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var locationService: LocationService
    @State var searchText = ""
    @State var selectedDeal: Deal?
    @State var showBarCrawl = false

    var filteredVenues: [Venue] {
        if searchText.isEmpty { return firestoreService.venues }
        return firestoreService.venues.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
        ZStack(alignment: .top) {
            GoogleMapView(
                venues: filteredVenues,
                deals: firestoreService.deals,
                selectedDeal: $selectedDeal,
                userLocation: locationService.userLocation ?? locationService.defaultLocation
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                TextField("Search venues...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Button(action: { showBarCrawl = true }) {
                    HStack {
                        Image(systemName: "figure.walk")
                        Text("Plan a Bar Crawl")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(.ultraThinMaterial)

            if let deal = selectedDeal {
                VStack {
                    Spacer()
                    MapDealCardView(deal: deal)
                        .padding()
                }
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showBarCrawl) {
            NavigationStack {
                BarCrawlView()
                    .environmentObject(firestoreService)
                    .environmentObject(locationService)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showBarCrawl = false }
                        }
                    }
            }
        }
        .onAppear {
            if firestoreService.venues.isEmpty { firestoreService.fetchVenues() }
            if firestoreService.deals.isEmpty { firestoreService.fetchDeals() }
        }
        }
    }
}

#Preview {
    MapTabView()
        .environmentObject(FirestoreService())
        .environmentObject(LocationService())
}

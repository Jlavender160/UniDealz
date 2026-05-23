import SwiftUI

struct HomeView: View {
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // featured deals banner
                    if !firestoreService.featuredDeals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Featured Deals")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            DealCarouselView(deals: firestoreService.featuredDeals)
                                .frame(height: 220)
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.cardBackground)
                    }

                    VStack(alignment: .leading, spacing: 24) {

                        // popular section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(firestoreService.deals.sorted { $0.averageRating > $1.averageRating }.prefix(5)) { deal in
                                        NavigationLink(destination: DealDetailView(deal: deal)) {
                                            DealCardView(deal: deal)
                                                .frame(width: 300)
                                        }
                                        .buttonStyle(.plain)
                                        .scrollTargetLayout()
                                    }
                                }
                                .padding(.horizontal)
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                        }

                        // food only section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Food Deals")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(firestoreService.deals.filter { $0.category == "food" }) { deal in
                                        NavigationLink(destination: DealDetailView(deal: deal)) {
                                            DealCardView(deal: deal)
                                                .frame(width: 300)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                        }

                        // ocean wednesday deals section
                        let oceanWednesdayDeals = firestoreService.deals.filter {
                            $0.tag == "ocean" && $0.daysAvailable.contains("Wednesday")
                        }
                        if !oceanWednesdayDeals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ocean Wednesday Deals")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(oceanWednesdayDeals) { deal in
                                            NavigationLink(destination: DealDetailView(deal: deal)) {
                                                DealCardView(deal: deal)
                                                    .frame(width: 300)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .scrollTargetLayout()
                                }
                                .scrollTargetBehavior(.viewAligned)
                            }
                        }

                        // all deals section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Deals Near You")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(firestoreService.deals) { deal in
                                        NavigationLink(destination: DealDetailView(deal: deal)) {
                                            DealCardView(deal: deal)
                                                .frame(width: 300)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                        }

                    }
                    .padding(.vertical, 20)
                }
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("UniDealz")
                        .font(.title2)
                        .bold()
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(FirestoreService())
}

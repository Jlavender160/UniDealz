import SwiftUI

struct LikesView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @State var selectedFilter = "All"
    let filters = ["All", "Food", "Drinks"]

    var filteredDeals: [Deal] {
        switch selectedFilter {
        case "Food": return firestoreService.favouriteDeals.filter { $0.category == "food" }
        case "Drinks": return firestoreService.favouriteDeals.filter { $0.category == "drinks" }
        default: return firestoreService.favouriteDeals
        }
    }

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    ForEach(filters, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            Text(filter)
                                .font(.subheadline)
                                .bold()
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedFilter == filter ? AppColors.primary : AppColors.cardBackground)
                                .foregroundColor(selectedFilter == filter ? .white : AppColors.textPrimary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)

                if filteredDeals.isEmpty {
                    Spacer()
                    Text("No liked deals yet")
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredDeals) { deal in
                                NavigationLink(destination: DealDetailView(deal: deal)) {
                                    LikesCardView(deal: deal, imageURL: deal.venueImageURL)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Likes")
            .background(AppColors.background.ignoresSafeArea())
            .onAppear {
                firestoreService.updateFavouriteDeals()
            }
        }
    }
}

#Preview {
    LikesView()
        .environmentObject(FirestoreService())
}

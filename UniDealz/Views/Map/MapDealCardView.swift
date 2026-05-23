import SwiftUI

struct MapDealCardView: View {
    let deal: Deal
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: deal.venueImageURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(AppColors.cardBackground)
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(deal.venueName)
                    .font(.headline)
                Text(deal.title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= Int(deal.averageRating.rounded()) ? "star.fill" : "star")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }

            Spacer()

            Button(action: {
                if let id = deal.id {
                    firestoreService.toggleFavourite(dealId: id)
                }
            }) {
                Image(systemName: firestoreService.isFavourite(dealId: deal.id ?? "") ? "heart.fill" : "heart")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

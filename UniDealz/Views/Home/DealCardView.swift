import SwiftUI

struct DealCardView: View {
    let deal: Deal
    @EnvironmentObject var firestoreService: FirestoreService

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: deal.venueImageURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Rectangle().fill(AppColors.cardBackground)
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                default:
                    Rectangle().fill(AppColors.cardBackground)
                }
            }
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(8)

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
                    Text("(\(deal.reviewCount))")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Button(action: {
                if let id = deal.id {
                    firestoreService.toggleFavourite(dealId: id)
                }
            }) {
                let liked = firestoreService.isFavourite(dealId: deal.id ?? "")
                Image(systemName: liked ? "heart.fill" : "heart")
                    .foregroundColor(liked ? AppColors.primary : .gray)
                    .font(.title3)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

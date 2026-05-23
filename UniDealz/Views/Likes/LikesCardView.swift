import SwiftUI

struct LikesCardView: View {
    let deal: Deal
    let imageURL: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            Rectangle().fill(Color(.systemGray5))
                                .overlay(Image(systemName: "photo").foregroundColor(.gray))
                        default:
                            Rectangle().fill(Color(.systemGray5)).overlay(ProgressView())
                        }
                    }
                    .clipped()
                )
                .cornerRadius(8)

            Text(deal.venueName)
                .font(.subheadline)
                .bold()
                .lineLimit(1)

            Text(deal.category.capitalized)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(8)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

import SwiftUI

struct DealCarouselView: View {
    let deals: [Deal]

    var body: some View {
        TabView {
            ForEach(deals) { deal in
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: deal.venueImageURL)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(AppColors.cardBackground).overlay(ProgressView())
                    }

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(deal.venueName)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(deal.title)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    .padding()
                    .padding(.bottom, 28)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .id(deals.map { $0.venueName }.joined())
    }
}

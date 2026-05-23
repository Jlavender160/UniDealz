import SwiftUI

struct DealDetailView: View {
    let deal: Deal
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var notificationService: NotificationService
    @State var showingWriteReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: deal.venueImageURL)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(AppColors.cardBackground).overlay(ProgressView())
                }
                .frame(height: 220)
                .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(deal.venueName)
                            .font(.title)
                            .bold()
                        Spacer()
                        Button(action: {
                            if let id = deal.id {
                                let isLiking = !firestoreService.isFavourite(dealId: id)
                                firestoreService.toggleFavourite(dealId: id)
                                if isLiking {
                                    notificationService.sendLikedNotification(deal: deal)
                                }
                            }
                        }) {
                            let liked = firestoreService.isFavourite(dealId: deal.id ?? "")
                            Image(systemName: liked ? "heart.fill" : "heart")
                                .foregroundColor(liked ? AppColors.primary : .gray)
                                .font(.title2)
                        }
                    }

                    Text(deal.title)
                        .font(.title3)
                        .foregroundColor(AppColors.textSecondary)
                    VStack(alignment: .center, spacing: 12) {
                        Text(deal.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        Divider()

                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(AppColors.primary)
                            Text(deal.daysAvailable.count == 7 ? "Everyday" : deal.daysAvailable.joined(separator: ", "))
                                .font(.subheadline)
                        }
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(AppColors.primary)
                            Text("\(deal.startTime) - \(deal.endTime)")
                                .font(.subheadline)
                        }
                        if deal.requiresStudentID {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(AppColors.primary)
                                Text("Student ID required")
                                    .font(.subheadline)
                            }
                        }
                        if let expiry = deal.expiryDate {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                                Text("Expires \(expiry, style: .date)")
                                    .font(.subheadline)
                            }
                        }
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(AppColors.primary)
                            Text(deal.category.capitalized)
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)

                    if let link = deal.link, let url = URL(string: link) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "safari")
                                Text("View Deal")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }

                    Divider()

                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(deal.averageRating.rounded()) ? "star.fill" : "star")
                                .foregroundColor(.orange)
                        }
                        Text(String(format: "%.1f", deal.averageRating))
                            .bold()
                        Text("(\(deal.reviewCount) reviews)")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    HStack {
                        Text("Reviews")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button(action: { showingWriteReview = true }) {
                            Label("Write Review", systemImage: "square.and.pencil")
                                .font(.subheadline)
                                .foregroundColor(AppColors.primary)
                        }
                    }

                    if firestoreService.reviews.isEmpty {
                        Text("No reviews yet. Be the first!")
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(firestoreService.reviews) { review in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(review.userName)
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                                .foregroundColor(.orange)
                                                .font(.caption)
                                        }
                                    }
                                }
                                Text(review.text)
                                Text(review.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(deal.venueName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingWriteReview) {
            WriteReviewView(preselectedDealId: deal.id ?? "")
        }
        .onAppear {
            if let id = deal.id {
                firestoreService.fetchReviews(for: id)
            }
        }
    }
}

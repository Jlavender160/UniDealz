import SwiftUI

// List → ForEach → VStack(alignment: .leading) pattern adapted from
// DynamicListLab tutorial (ITEC31041 lab)
struct ReviewsListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @State var showWriteReview = false

    var body: some View {
        List {
            if firestoreService.reviews.isEmpty {
                Text("No reviews yet")
                    .foregroundColor(AppColors.textSecondary)
            }

            ForEach(firestoreService.reviews) { review in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= review.rating ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    Text(review.text)
                    Text(review.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    if let id = firestoreService.reviews[index].id {
                        firestoreService.deleteReview(reviewId: id)
                    }
                }
                firestoreService.fetchUserReviews()
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("My Reviews")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showWriteReview = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView()
        }
        .onAppear {
            firestoreService.fetchUserReviews()
        }
    }
}

#Preview {
    ReviewsListView()
        .environmentObject(FirestoreService())
}

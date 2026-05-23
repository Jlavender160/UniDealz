import SwiftUI

struct WriteReviewView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @Environment(\.dismiss) var dismiss
    var preselectedDealId: String = ""
    @State var selectedDealId = ""
    @State var rating = 3
    @State var reviewText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Select Deal") {
                    Picker("Deal", selection: $selectedDealId) {
                        Text("Select a deal").tag("")
                        ForEach(firestoreService.deals) { deal in
                            Text("\(deal.venueName) - \(deal.title)")
                                .tag(deal.id ?? "")
                        }
                    }
                }

                Section("Rating") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: { rating = star }) {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Review") {
                    TextEditor(text: $reviewText)
                        .frame(minHeight: 100)
                }

                Button("Submit Review") {
                    guard !selectedDealId.isEmpty, !reviewText.isEmpty else { return }
                    firestoreService.addReview(dealId: selectedDealId, rating: rating, text: reviewText)
                    dismiss()
                }
                .foregroundColor(AppColors.primary)
                .disabled(selectedDealId.isEmpty || reviewText.isEmpty)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Write Review")
            .onAppear {
                if !preselectedDealId.isEmpty {
                    selectedDealId = preselectedDealId
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    WriteReviewView()
        .environmentObject(FirestoreService())
}

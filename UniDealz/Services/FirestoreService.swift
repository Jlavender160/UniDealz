import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

// firestoreService structure (ObservableObject, @Published array, private db,
// getDocuments closure pattern) adapted from Firestore tutorial
class FirestoreService: ObservableObject {
    @Published var deals: [Deal] = []
    @Published var featuredDeals: [Deal] = []
    @Published var venues: [Venue] = []
    @Published var reviews: [Review] = []
    @Published var userProfile: UserProfile?
    @Published var favouriteDeals: [Deal] = []
    @Published var favouriteDealIds: [String] = []

    private var db = Firestore.firestore()

    func fetchDeals() {
        db.collection("deals").getDocuments { (snapshot, error) in
            if error != nil { return }
            guard let documents = snapshot?.documents else { return }
            
            Task { @MainActor in
                self.deals = documents.compactMap { doc in
                    do {
                        var deal = try doc.data(as: Deal.self)
                        if deal.id == nil { deal.id = doc.documentID }
                        return deal
                    } catch {
                        return nil
                    }
                }
                self.enrichDeals()
            }
        }
    }

    func fetchVenues() {
        db.collection("venues").getDocuments { (snapshot, error) in
            if error != nil { return }
            guard let documents = snapshot?.documents else { return }
            
            Task { @MainActor in
                self.venues = documents.compactMap { try? $0.data(as: Venue.self) }
                self.enrichDeals()
            }
        }
    }

    private func enrichDeals() {
        guard !deals.isEmpty, !venues.isEmpty else { return }
        let venueMap = Dictionary(uniqueKeysWithValues: venues.compactMap { v in
            v.id.map { ($0, v) }
        })
        deals = deals.map { deal in
            var updated = deal
            if let venue = venueMap[deal.venueId] {
                updated.venueImageURL = venue.imageURL
                updated.venueName = venue.name
                updated.latitude = venue.latitude
                updated.longitude = venue.longitude
            }
            return updated
        }
        featuredDeals = deals.filter { $0.isFeatured }
        updateFavouriteDeals()
    }

    func updateFavouriteDeals() {
        favouriteDeals = deals.filter { deal in
            guard let id = deal.id else { return false }
            return favouriteDealIds.contains(id)
        }
    }

    func fetchReviews(for dealId: String) {
        db.collection("reviews")
            .whereField("dealId", isEqualTo: dealId)
            .order(by: "createdAt", descending: true)
            .getDocuments { (snapshot, error) in
                if error != nil { return }
                guard let documents = snapshot?.documents else { return }
                
                Task { @MainActor in
                    self.reviews = documents.compactMap { try? $0.data(as: Review.self) }
                }
            }
    }

    func fetchUserReviews() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("reviews")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments { (snapshot, error) in
                if error != nil { return }
                guard let documents = snapshot?.documents else { return }
                
                Task { @MainActor in
                    self.reviews = documents.compactMap { try? $0.data(as: Review.self) }
                }
            }
    }

    // saves the review to Firestore, then recalculates the deal's average rating
    // and writes the updated stats back to the deal document.
    // the local array is also updated immediately so the star rating on screen
    // changes without the user needing to pull to refresh.
    func addReview(dealId: String, rating: Int, text: String) {
        guard let user = Auth.auth().currentUser else { return }
        let review = Review(dealId: dealId, userId: user.uid, userName: user.displayName ?? "Anonymous", rating: rating, text: text, createdAt: Date())
        _ = try? db.collection("reviews").addDocument(from: review)

        guard let idx = deals.firstIndex(where: { $0.id == dealId }) else { return }
        let newCount = deals[idx].reviewCount + 1
        // running average formula: multiply old average by old count to get the sum,
        // add the new rating, then divide by the new count.
        let newAverage = ((deals[idx].averageRating * Double(deals[idx].reviewCount)) + Double(rating)) / Double(newCount)
        // write the updated stats to Firestore so other users see the new rating on their next load
        db.collection("deals").document(dealId).updateData(["reviewCount": newCount, "averageRating": newAverage])
        deals[idx].reviewCount = newCount
        deals[idx].averageRating = newAverage
        // if this deal is also in the featured section, update that copy too
        if let fIdx = featuredDeals.firstIndex(where: { $0.id == dealId }) {
            featuredDeals[fIdx].reviewCount = newCount
            featuredDeals[fIdx].averageRating = newAverage
        }
    }

    func deleteReview(reviewId: String) {
        db.collection("reviews").document(reviewId).delete()
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { (snapshot, error) in
            if error != nil { return }
            
            Task { @MainActor in
                self.userProfile = try? snapshot?.data(as: UserProfile.self)
                if self.userProfile == nil {
                    let user = Auth.auth().currentUser
                    self.createUserProfile(
                        email: user?.email ?? "",
                        displayName: user?.displayName ?? "User"
                    )
                }
                self.favouriteDealIds = self.userProfile?.favouriteDealIds ?? []
                self.updateFavouriteDeals()
            }
        }
    }

    func createUserProfile(email: String, displayName: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let profile = UserProfile(
            email: email,
            displayName: displayName,
            favouriteDealIds: [],
            notificationsEnabled: true,
            fontSize: 16,
            darkMode: false
        )
        do {
            try db.collection("users").document(uid).setData(from: profile)
        } catch {
        }
    }

    func updateUserProfile(_ profile: UserProfile) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(uid).setData(from: profile)
            self.userProfile = profile
        } catch {
        }
    }

    func toggleFavourite(dealId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isLiked = favouriteDealIds.contains(dealId)
        if isLiked {
            favouriteDealIds.removeAll { $0 == dealId }
            db.collection("users").document(uid).updateData([
                "favouriteDealIds": FieldValue.arrayRemove([dealId])
            ])
        } else {
            favouriteDealIds.append(dealId)
            db.collection("users").document(uid).updateData([
                "favouriteDealIds": FieldValue.arrayUnion([dealId])
            ])
        }
        updateFavouriteDeals()
    }

    func isFavourite(dealId: String) -> Bool {
        return favouriteDealIds.contains(dealId)
    }

    func clearUserData() {
        userProfile = nil
        favouriteDealIds = []
        favouriteDeals = []
        reviews = []
    }
}

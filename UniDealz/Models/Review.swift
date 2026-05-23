import Foundation
import FirebaseFirestore

// @DocumentID var id: String? pattern from Firestore tutorial (ITEC31041 lab)
struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    var dealId: String
    var userId: String
    var userName: String
    var rating: Int
    var text: String
    var createdAt: Date
}

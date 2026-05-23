import Foundation
import FirebaseFirestore

// @DocumentID var id: String? pattern from Firestore tutorial (ITEC31041 lab)
struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var favouriteDealIds: [String]
    var notificationsEnabled: Bool
    var fontSize: Double
    var darkMode: Bool
}

import Foundation
import FirebaseFirestore

// @DocumentID var id: String? pattern from Firestore tutorial (ITEC31041 lab)
struct Venue: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var imageURL: String
    var category: String
    var latitude: Double
    var longitude: Double
    var address: String
}

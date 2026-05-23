import Foundation
import FirebaseFirestore

// @DocumentID var id: String? pattern from Firestore tutorial (ITEC31041 lab)
struct Deal: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var venueId: String
    var title: String
    var category: String
    var description: String
    var daysAvailable: [String]
    var startTime: String
    var endTime: String
    var requiresStudentID: Bool
    var expiryDate: Date?
    var isFeatured: Bool
    var averageRating: Double
    var reviewCount: Int
    var link: String?
    var tag: String?

    // set at runtime by enrichDeals() from the linked venue, not stored in Firestore
    var venueImageURL: String = ""
    var venueName: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    enum CodingKeys: String, CodingKey {
        case venueId, title, category, description, daysAvailable
        case startTime, endTime, requiresStudentID, expiryDate
        case isFeatured, averageRating, reviewCount, link, tag
    }
}

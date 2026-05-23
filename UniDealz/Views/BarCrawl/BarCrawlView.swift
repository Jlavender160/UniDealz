import SwiftUI

//List pattern adapted from DynamicListLab tutorial
struct BarCrawlView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var locationService: LocationService
    @State var selectedVenueIds: Set<String> = []
    @State var showMap = false

    var nightlifeVenues: [Venue] {
        firestoreService.venues.filter {
            $0.category == "nightlife" || $0.category == "bar" || $0.category == "club"
        }
    }

    // auto-sorted by earliest deal end time today so you hit expiring deals first
    var selectedVenues: [Venue] {
        nightlifeVenues
            .filter { selectedVenueIds.contains($0.id ?? "") }
            .sorted { a, b in
                let aEnd = earliestEndTime(for: dealsForVenueToday(a))
                let bEnd = earliestEndTime(for: dealsForVenueToday(b))
                switch (aEnd, bEnd) {
                case (let a?, let b?): return a < b
                case (.some, .none):   return true
                case (.none, .some):   return false
                default:               return false
                }
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Select up to 6 venues — route auto-sorts by deal end times")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            List(nightlifeVenues) { venue in
                VenueRowView(
                    venue: venue,
                    deals: dealsForVenueToday(venue),
                    isSelected: selectedVenueIds.contains(venue.id ?? "")
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    let id = venue.id ?? ""
                    if selectedVenueIds.contains(id) {
                        selectedVenueIds.remove(id)
                    } else if selectedVenueIds.count < 6 {
                        selectedVenueIds.insert(id)
                    }
                }
            }
            .listStyle(.plain)

            VStack(spacing: 10) {
                if selectedVenueIds.count >= 2 {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.badge.checkmark.fill")
                            .foregroundColor(AppColors.primary)
                            .font(.caption)
                        Text("Route sorted by deal end times")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

                Button(action: { showMap = true }) {
                    HStack {
                        Image(systemName: "figure.walk")
                        Text("Plan Route (\(selectedVenueIds.count) stops)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedVenueIds.count >= 2 ? AppColors.primary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(selectedVenueIds.count < 2)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Bar Crawl")
        .fullScreenCover(isPresented: $showMap) {
            BarCrawlMapView(venues: selectedVenues, deals: firestoreService.deals)
                .environmentObject(locationService)
        }
    }

    private func dealsForVenueToday(_ venue: Venue) -> [Deal] {
        guard let venueId = venue.id else { return [] }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let todayName = dayFormatter.string(from: Date())
        return firestoreService.deals
            .filter { $0.venueId == venueId && $0.daysAvailable.contains(todayName) }
            .sorted { (parseTime($0.endTime) ?? .distantFuture) < (parseTime($1.endTime) ?? .distantFuture) }
    }

    private func earliestEndTime(for deals: [Deal]) -> Date? {
        deals.compactMap { parseTime($0.endTime) }.min()
    }

}

// venue row with deal time badges

private struct VenueRowView: View {
    let venue: Venue
    let deals: [Deal]
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name).font(.headline)
                Text(venue.address)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                if !deals.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(deals) { deal in
                            DealTimeBadge(deal: deal)
                        }
                    }
                }
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DealTimeBadge: View {
    let deal: Deal

    var timeLabel: String {
        "\(formatTime(deal.startTime))–\(formatTime(deal.endTime))"
    }

    var isEndingSoon: Bool {
        guard let end = parseTime(deal.endTime) else { return false }
        let remaining = end.timeIntervalSinceNow
        return remaining > 0 && remaining < 3600
    }

    var badgeColor: Color {
        isEndingSoon ? .orange : AppColors.primary
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isEndingSoon ? "exclamationmark.clock" : "clock")
                .font(.system(size: 9))
            Text(timeLabel)
                .font(.caption2).bold()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(badgeColor.opacity(0.15))
        .foregroundColor(badgeColor)
        .cornerRadius(6)
    }

}

#Preview {
    BarCrawlView()
        .environmentObject(FirestoreService())
}

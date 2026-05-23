import SwiftUI
import GoogleMaps

struct BarCrawlMapView: View {
    let venues: [Venue]
    let deals: [Deal]
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @EnvironmentObject var locationService: LocationService
    @State var routeCoordinates: [CLLocationCoordinate2D] = []
    @State var isLoading = true
    @State private var visitedVenueIds: Set<String> = []
    @State private var selectedVenue: Venue? = nil

    // filters out any venues the user has already visited.
    // because it's a computed property, SwiftUI automatically refreshes the map and chip strip
    // the moment a venue gets added to visitedVenueIds, no manual refresh needed.
    var remainingVenues: [Venue] {
        venues.filter { !visitedVenueIds.contains($0.id ?? "") }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GoogleMapView(
                    venues: remainingVenues,
                    deals: [],
                    selectedDeal: .constant(nil),
                    userLocation: locationService.userLocation ?? CLLocationCoordinate2D(latitude: 52.9548, longitude: -1.1581),
                    routeCoordinates: routeCoordinates
                )
                .ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading route...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }

                VStack {
                    Spacer()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(remainingVenues.enumerated()), id: \.element.id) { index, venue in
                                HStack(spacing: 6) {
                                    Text("\(index + 1)")
                                        .font(.caption).bold()
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(AppColors.primary)
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(venue.name)
                                            .font(.caption).bold()
                                        if let deal = primaryDealForVenue(venue) {
                                            let ending = isDealEndingSoon(deal)
                                            Text("until \(formatTime(deal.endTime))")
                                                .font(.caption2)
                                                .foregroundColor(ending ? .red : AppColors.primary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.regularMaterial)
                                .cornerRadius(20)
                                .onTapGesture { selectedVenue = venue }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Bar Crawl Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { openInGoogleMaps() } label: {
                        Image(systemName: "map.fill")
                    }
                    .disabled(remainingVenues.isEmpty)
                }
            }
            .onAppear { fetchWalkingRoute(stops: remainingVenues) }
            //sheet
            .sheet(item: $selectedVenue) { venue in
                VenueVisitSheet(venue: venue) {
                    let id = venue.id ?? ""
                    // calculate the new list of stops before updating state.
                    // before fetchwalking
                    let newRemaining = venues.filter { $0.id != id && !visitedVenueIds.contains($0.id ?? "") } //computed property so i dont have to manually update a stored value
                    visitedVenueIds.insert(id)   // removes the chip and marker from the map
                    selectedVenue = nil           // dismisses the sheet
                    isLoading = true
                    fetchWalkingRoute(stops: newRemaining)  // re-routes from current location to remaining stops
                }
            }
        }
    }

    // gets the deal at this venue that's ending soonest today.
    // sorting by end time for time-sensitive deal shows on the chip, so the user knows what to prioritise.
    private func primaryDealForVenue(_ venue: Venue) -> Deal? {
        guard let venueId = venue.id else { return nil }
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let todayName = dayFormatter.string(from: Date())
        return deals
            .filter { $0.venueId == venueId && $0.daysAvailable.contains(todayName) }
            .sorted { (parseTime($0.endTime) ?? .distantFuture) < (parseTime($1.endTime) ?? .distantFuture) }
            .first
    }

    // checks if the deal ends within the next hour.
    // if it does, the time label turns red on the chip so the user knows they need to hurry.
    private func isDealEndingSoon(_ deal: Deal) -> Bool {
        guard let end = parseTime(deal.endTime) else { return false }
        let remaining = end.timeIntervalSinceNow
        return remaining > 0 && remaining < 3600
    }

    private func openInGoogleMaps() {
        guard !remainingVenues.isEmpty else { return }
        let origin: String
        if let loc = locationService.userLocation {
            origin = "\(loc.latitude),\(loc.longitude)"
        } else {
            origin = "\(remainingVenues.first!.latitude),\(remainingVenues.first!.longitude)"
        }
        let destination = "\(remainingVenues.last!.latitude),\(remainingVenues.last!.longitude)"
        let waypoints = remainingVenues.dropLast().map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
        var urlString = "https://www.google.com/maps/dir/?api=1&origin=\(origin)&destination=\(destination)&travelmode=walking"
        if !waypoints.isEmpty { urlString += "&waypoints=\(waypoints)" }
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString) {
            openURL(url)
        }
    }

    // hits the Google Directions API to get a walking route through the remaining stops.
    // called on first load, and again each time a venue is marked as visited so the route stays up to date.
    private func fetchWalkingRoute(stops: [Venue]) {
        guard !stops.isEmpty else {
            // no stops left, clear the blue line off the map
            routeCoordinates = []
            isLoading = false
            return
        }

        // start from the user's real GPS position if we have it.
        // if location isn't available yet, fall back to the first venue as the origin.
        let origin: String
        if let loc = locationService.userLocation {
            origin = "\(loc.latitude),\(loc.longitude)"
        } else {
            origin = "\(stops.first!.latitude),\(stops.first!.longitude)"
        }

        let destination = "\(stops.last!.latitude),\(stops.last!.longitude)"

        var urlString = "https://maps.googleapis.com/maps/api/directions/json?"
        urlString += "origin=\(origin)&destination=\(destination)"

        if stops.count > 1 {
            // any stops in between become waypoints so Google routes through all of them.
            // optimize:true lets Google reorder the middle stops for a shorter walk if needed.
            let waypoints = stops.dropFirst().dropLast().map {
                "\($0.latitude),\($0.longitude)"
            }.joined(separator: "|")
            if !waypoints.isEmpty { urlString += "&waypoints=optimize:true|\(waypoints)" }
        }

        urlString += "&mode=walking&key=\(Config.googleDirectionsKey)"

        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        // the API returns an encoded polyline string, decode that into coordinates and pass back to the main thread to update the map.
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let overviewPolyline = route["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String {
                    let coords = decodePolyline(points)
                    DispatchQueue.main.async {
                        self.routeCoordinates = coords
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async { self.isLoading = false }
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }.resume()
    }

    //google encodes polyline coordinates as a compressed string to reduce response size.
    // converted polyline_decoder.py from https://github.com/geodav-tech/decode-google-maps-polyline.git and converted into swift
    //this function unpacks that string back into lat/lng pairs so we can draw the route line on the map.
    private func decodePolyline(_ encoded: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = encoded.startIndex
        var lat = 0, lng = 0

        while index < encoded.endIndex {
            var shift = 0, result = 0
            // read each character, subtract 63 to reverse Google's encoding offset,
            // then read 5 bits at a time and shift them into position
            repeat {
                let byte = Int(encoded[index].asciiValue ?? 0) - 63
                index = encoded.index(after: index)
                result |= (byte & 0x1F) << shift
                shift += 5
            } while index < encoded.endIndex && (Int(encoded[encoded.index(before: index)].asciiValue ?? 0) - 63) >= 0x20
            // each value is a delta which is the difference from the previous coordinate
            lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)

            shift = 0; result = 0
            repeat {
                let byte = Int(encoded[index].asciiValue ?? 0) - 63
                index = encoded.index(after: index)
                result |= (byte & 0x1F) << shift
                shift += 5
            } while index < encoded.endIndex && (Int(encoded[encoded.index(before: index)].asciiValue ?? 0) - 63) >= 0x20
            lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)

            // divide by 1e5 to convert back to real decimal coordinates, then add to the list
            coordinates.append(CLLocationCoordinate2D(
                latitude: Double(lat) / 1e5,
                longitude: Double(lng) / 1e5
            ))
        }
        return coordinates
    }
}

struct VenueVisitSheet: View {
    let venue: Venue
    let onMarkVisited: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(venue.name)
                .font(.title2).bold()
            Text(venue.address)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: onMarkVisited) {
                Text("Mark as Visited")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Button("Close") { dismiss() }
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}

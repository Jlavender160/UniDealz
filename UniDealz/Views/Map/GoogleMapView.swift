import SwiftUI
import GoogleMaps

// GoogleMapView structure adapted from GoogleMaps tutorial 
struct GoogleMapView: UIViewRepresentable {
    let venues: [Venue]
    let deals: [Deal]
    @Binding var selectedDeal: Deal?
    var userLocation: CLLocationCoordinate2D
    var routeCoordinates: [CLLocationCoordinate2D]? = nil

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: 52.9548,
            longitude: -1.1581,
            zoom: 14
        )
        let mapView = GMSMapView()
        mapView.camera = camera
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.parent = self
        mapView.clear()

        for venue in venues {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
            marker.title = venue.name
            marker.snippet = venue.address
            marker.icon = GMSMarker.markerImage(with: .systemGreen)
            marker.userData = venue.id
            marker.map = mapView
        }

        if let coords = routeCoordinates, coords.count >= 2 {
            let path = GMSMutablePath()
            for coord in coords { path.add(coord) }
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 4
            polyline.strokeColor = .systemBlue
            polyline.map = mapView
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView

        init(_ parent: GoogleMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let venueId = marker.userData as? String {
                parent.selectedDeal = parent.deals.first { $0.venueId == venueId }
            }
            return false
        }
    }
}

import SwiftUI
import MapKit

struct LocationView: View {
    let currentLatitude: Double
    let currentLongitude: Double
    let friendsLocations: [(Double, Double)] // List of friends' coordinates
    
    var body: some View {
        MapView(currentLatitude: currentLatitude, currentLongitude: currentLongitude, friendsLocations: friendsLocations)
    }
}

struct MapView: UIViewRepresentable {
    let currentLatitude: Double
    let currentLongitude: Double
    let friendsLocations: [(Double, Double)]
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Add marker for current location
        let currentLocation = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        let currentAnnotation = MKPointAnnotation()
        currentAnnotation.coordinate = currentLocation
        currentAnnotation.title = "Current Location"
        view.addAnnotation(currentAnnotation)
        
        // Add markers for friends' locations
        for friendLocation in friendsLocations {
            let friendCoordinate = CLLocationCoordinate2D(latitude: friendLocation.0, longitude: friendLocation.1)
            let friendAnnotation = MKPointAnnotation()
            friendAnnotation.coordinate = friendCoordinate
            friendAnnotation.title = "Friend's Location"
            view.addAnnotation(friendAnnotation)
        }
        
        // Set map region
        let coordinateRegion = MKCoordinateRegion(
            center: currentLocation,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000)
        view.setRegion(coordinateRegion, animated: true)
    }
}

struct ContentView: View {
    var body: some View {
        LocationView(
            currentLatitude: 37.7749,
            currentLongitude: -122.4194,
            friendsLocations: [(37.7805, -122.4123), (37.7880, -122.4075)] // Example friends' locations
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

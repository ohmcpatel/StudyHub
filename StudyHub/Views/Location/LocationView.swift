import SwiftUI
import MapKit
import Firebase


class CustomPointAnnotation: MKPointAnnotation {
    var friendLocation: (Double, Double)?
    var uid: String = "" // Additional property for uid
}


struct LocationView: View {
    @ObservedObject var viewModel: LocationViewModel
    @State private var selectedFriend: (Double, Double, String)? = nil
    
    var body: some View {
        ZStack {
            MapView(viewModel: viewModel, selectedFriend: $selectedFriend)
                .onAppear {
                    viewModel.populateCurrentLocation()
                    viewModel.fetchFriendsLocations()
                }
            
            if let friend = selectedFriend {
                FriendProfileView(friend: friend, isPresented: $selectedFriend, viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
}

struct ContentView: View {
    var body: some View {
        LocationView(viewModel: LocationViewModel())
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: LocationViewModel
    @Binding var selectedFriend: (Double, Double, String)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)
        
        let currentLocation = CLLocationCoordinate2D(latitude: viewModel.currentLatitude, longitude: viewModel.currentLongitude)
//        let currentAnnotation = MKPointAnnotation()
//        currentAnnotation.coordinate = currentLocation
//        currentAnnotation.title = "Current Location"
//        view.addAnnotation(currentAnnotation)
        print(viewModel.friendsLocations)
        for friendLocation in viewModel.friendsLocations {
            print("friendLocation \(friendLocation)")

            let friendCoordinate = CLLocationCoordinate2D(latitude: friendLocation.0, longitude: friendLocation.1)
            let friendAnnotation = CustomPointAnnotation()
            friendAnnotation.coordinate = friendCoordinate
            friendAnnotation.uid = friendLocation.2
            friendAnnotation.title = friendLocation.2
            friendAnnotation.friendLocation = (friendLocation.0, friendLocation.1)
            view.addAnnotation(friendAnnotation)
            print("Added friend annotation at: \(friendLocation.0), \(friendLocation.1)")

        }
        
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        view.setRegion(coordinateRegion, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? CustomPointAnnotation {
                parent.selectedFriend = (annotation.friendLocation!.0, annotation.friendLocation!.1, annotation.uid)
            }
        }
    }
}


struct FriendProfileView: View {
    var friend: (Double, Double, String)
    @Binding var isPresented: (Double, Double, String)?
    @ObservedObject var viewModel: LocationViewModel
    var uid = Auth.auth().currentUser!.uid

    var body: some View {
        ZStack {
            // Transparent overlay to capture tap gesture
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = nil
                }
            
            VStack(spacing: 20) {
                Text("Friend's Profile")
                    .font(.title)
                    .foregroundColor(Color(hex: 0xFA4A0C, opacity: 1))
                
                ProfileDetailView(friend: friend, viewModel: viewModel)
                
                Button(action: {viewModel.sendInviteFromTo(uid1: uid, uid2: friend.2)
                }) {
                    Text("Request to Study")
                        .foregroundColor(.black)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xFA4A0C, opacity: 1), Color.white]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white.opacity(0.8)) // Semi-transparent white background
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
            .frame(maxWidth: .infinity) // Make it wider
        }
    }
}


struct ProfileDetailView: View {
    var friend: (Double, Double, String)
    @ObservedObject var viewModel: LocationViewModel
    var uid = Auth.auth().currentUser!.uid
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.name)
                .font(.headline)
            ForEach(viewModel.classes, id: \.self) { className in
                            Text(className)
                                .font(.subheadline)
                        }
        }
        .onAppear{
            viewModel.fetchUserName(uid: friend.2)
            viewModel.fetchSharedClasses(uidOne: friend.2, uidTwo: uid)
        }
    }
}

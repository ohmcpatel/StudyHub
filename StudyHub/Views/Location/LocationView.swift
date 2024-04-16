import SwiftUI
import MapKit
import Firebase

class CustomPointAnnotation: MKPointAnnotation {
    var friendLocation: FriendLocation?
}

// Define a struct for the main view
struct LocationView: View {
    @ObservedObject var viewModel: LocationViewModel
    @State private var selectedFriend: FriendLocation?

    var body: some View {
        ZStack {

            // MapView to display friends' locations
            MapView(viewModel: viewModel, selectedFriend: $selectedFriend)
                .onAppear {
                    viewModel.populateCurrentLocation()
                    viewModel.fetchFriendsLocations()
                }
            
            // FriendProfileView to display selected friend's profile
            if let friend = selectedFriend {
                FriendProfileView(friend: friend, isPresented: $selectedFriend, viewModel: viewModel)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

// ContentView struct for previews and app entry point
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

// MapView to display the map with friends' locations
struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: LocationViewModel
    @Binding var selectedFriend: FriendLocation?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.removeAnnotations(view.annotations)

        let currentLocation = CLLocationCoordinate2D(latitude: viewModel.currentLatitude, longitude: viewModel.currentLongitude)

        // Add friends' locations as annotations
        for friendLocation in viewModel.friendsLocations {
            let friendCoordinate = CLLocationCoordinate2D(latitude: friendLocation.latitude, longitude: friendLocation.longitude)
            let friendAnnotation = CustomPointAnnotation()
            friendAnnotation.coordinate = friendCoordinate
            friendAnnotation.friendLocation = friendLocation
            friendAnnotation.title = friendLocation.name
            view.addAnnotation(friendAnnotation)
        }

        // Set map region to center around the current location
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

        // When a friend annotation is selected, update the selected friend state
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? CustomPointAnnotation,
               let friendLocation = annotation.friendLocation {
                parent.selectedFriend = friendLocation
            }
        }
    }
}

// FriendProfileView to display a selected friend's profile
struct FriendProfileView: View {
    var friend: FriendLocation
    @Binding var isPresented: FriendLocation?
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

            // Profile details and request button
            VStack(spacing: 20) {
                Text("\(friend.name)'s Profile")
                    .font(.title)
                    .foregroundColor(Color(hex: 0xFA4A0C, opacity: 1))
                
                // Pass the friend's name to ProfileDetailView
                ProfileDetailView(friend: friend, viewModel: viewModel)
                
                // Request to Study button
                Button(action: {
                    viewModel.sendInviteFromTo(uid1: uid, uid2: friend.documentID)
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

import SwiftUI
import FirebaseAuth

// ProfileDetailView to display a friend's profile details
struct ProfileDetailView: View {
    var friend: FriendLocation
    @ObservedObject var viewModel: LocationViewModel
    var uid = Auth.auth().currentUser!.uid
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Display the friend's name

            
            // Section header for shared classes
            Text("Here are the classes you share:")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Display shared classes
            if viewModel.classes.isEmpty {
                Text("No classes shared yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(viewModel.classes, id: \.self) { className in
                        HStack {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(.blue)
                            Text(className)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.leading, 10) // Add padding to the left for the list
            }
        }
        .padding()
        .onAppear {
            // Fetch shared classes
            viewModel.fetchSharedClasses(uidOne: friend.documentID, uidTwo: uid)
        }
    }
}


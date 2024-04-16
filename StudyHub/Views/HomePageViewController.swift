import SwiftUI
import Firebase // Import Firebase

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

struct HomePageViewController: View {
    // Inject the Firebase Firestore instance
    let locationManager = LocationManager()
    let db = Firestore.firestore()
    
    var body: some View {
        TabView {
            HomePageView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ContentView()
                .tabItem {
                    Image(systemName: "location")
                    Text("Location")
                }
            ClassScheduleView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            StudyTimerView()
                .tabItem{
                    Image(systemName: "clock")
                    Text("Timer")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }.accentColor(Color(hex: 0xFA4A0C, opacity: 1))
        .onAppear {
            // Update Firestore document with latitude and longitude
            locationManager.getCurrentLocation { coordinate, error in
                if let coordinate = coordinate {
                    updateLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                } else if let error = error {
                    print("Error getting location: \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    func updateLocation(latitude: Double, longitude: Double) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        // Reference to the document
        let docRef = db.collection("users").document(uid)
        
        // Update latitude and longitude fields in the document
        docRef.updateData([
            "latitude": latitude,
            "longitude": longitude
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}


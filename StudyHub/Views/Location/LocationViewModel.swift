import Foundation
import Firebase

class LocationViewModel: ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var currentLatitude: Double = 0
    @Published var currentLongitude: Double = 0
    @Published var friendsLocations: [(Double, Double, String)] = []
    @Published var classes: [String] = []
    @Published var name: String = ""

    

    let locationManager = LocationManager()
    
    func populateCurrentLocation() {
        locationManager.getCurrentLocation { coordinate, error in
            if let coordinate = coordinate {
                self.currentLatitude = coordinate.latitude
                self.currentLongitude = coordinate.longitude
            } else if let error = error {
                print("Error getting location: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchFriendsLocations() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        
        db.collection("users").whereField("Status", isEqualTo: true)
            .whereField(FieldPath.documentID(), isNotEqualTo: uid)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error getting active users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No active users found")
                    return
                }
                
                var locations: [(Double, Double, String)] = []
                
                for document in documents {
                    if let latitude = document.data()["latitude"] as? Double,
                       let longitude = document.data()["longitude"] as? Double {
                        locations.append((latitude, longitude, document.documentID))
                    }
                }
                
                self.friendsLocations = locations
            }
    }
    
    func fetchUserName(uid: String) {
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching user info: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document not found")
                return
            }
            
            if let data = document.data(),
               let name = data["name"] as? String {
                self.name = name                // You can perform further actions with the user dat
            } else {
                print("User data is incomplete")
            }
        }
    }
    
    func fetchSharedClasses(uidOne: String, uidTwo: String) {
        var classesOne: Set<String> = []
        var classesTwo: Set<String> = []

        // Fetch classes for first user
        db.collection("users").document(uidOne).getDocument { document, error in
            if let error = error {
                print("Error fetching user info for \(uidOne): \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("User document not found for \(uidOne)")
                return
            }

            if let data = document.data(),
               let userClasses = data["classes"] as? [String] {
                classesOne = Set(userClasses)
            } else {
                print("User data is incomplete for \(uidOne)")
            }

            // Fetch classes for second user
            self.db.collection("users").document(uidTwo).getDocument { document, error in
                if let error = error {
                    print("Error fetching user info for \(uidTwo): \(error.localizedDescription)")
                    return
                }

                guard let document = document, document.exists else {
                    print("User document not found for \(uidTwo)")
                    return
                }

                if let data = document.data(),
                   let userClasses = data["classes"] as? [String] {
                    classesTwo = Set(userClasses)
                } else {
                    print("User data is incomplete for \(uidTwo)")
                }

                // Find shared classes
                let sharedClasses = Array(classesOne.intersection(classesTwo))
                self.classes = sharedClasses
            }
        }
    }
    
    func sendInviteFromTo(uid1: String, uid2: String) {
            // Add uid2 to invitesSent of user with uid1
            let user1Ref = db.collection("users").document(uid1)
            user1Ref.updateData(["invitesSent": FieldValue.arrayUnion([uid2])]) { error in
                if let error = error {
                    print("Error updating invitesSent for user \(uid1): \(error.localizedDescription)")
                } else {
                    print("Invite sent successfully from user \(uid1) to user \(uid2)")
                }
            }
            
            // Add uid1 to invitesReceived of user with uid2
            let user2Ref = db.collection("users").document(uid2)
            user2Ref.updateData(["invitesReceived": FieldValue.arrayUnion([uid1])]) { error in
                if let error = error {
                    print("Error updating invitesReceived for user \(uid2): \(error.localizedDescription)")
                } else {
                    print("Invite received successfully by user \(uid2) from user \(uid1)")
                }
            }
        }
}

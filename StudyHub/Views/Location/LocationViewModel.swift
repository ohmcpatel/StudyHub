import Foundation
import Firebase

// A structure to encapsulate friend's location data
struct FriendLocation {
    let latitude: Double
    let longitude: Double
    let documentID: String
    let name: String
}

class LocationViewModel: ObservableObject {
    private var db = Firestore.firestore()
    
    @Published var currentLatitude: Double = 0
    @Published var currentLongitude: Double = 0
    @Published var friendsLocations: [FriendLocation] = []
    @Published var classes: [String] = []
    @Published var name: String = ""

    let locationManager = LocationManager()
    
    func populateCurrentLocation() {
        // Get the current user ID from Firebase Authentication
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        
        // Get the current location using the location manager
        locationManager.getCurrentLocation { coordinate, error in
            if let coordinate = coordinate {
                // Update the published properties for current location
                self.currentLatitude = coordinate.latitude
                self.currentLongitude = coordinate.longitude
                
                // Create a reference to the current user's document in the "users" collection
                let userRef = self.db.collection("users").document(uid)
                
                // Update the current user's location in Firestore
                userRef.updateData([
                    "latitude": coordinate.latitude,
                    "longitude": coordinate.longitude
                ]) { error in
                    if let error = error {
                        print("Error updating current location for user \(uid): \(error.localizedDescription)")
                    } else {
                        print("Successfully updated current location for user \(uid).")
                    }
                }
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

        db.collection("users")
            .whereField("Status", isEqualTo: true)
            .whereField(FieldPath.documentID(), isNotEqualTo: uid)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching active users: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No active users found.")
                    return
                }
                
                var locations: [FriendLocation] = []
                
                // Use a DispatchGroup to wait for all async operations to complete
                let dispatchGroup = DispatchGroup()
                
                for document in documents {
                    guard let latitude = document.data()["latitude"] as? Double,
                          let longitude = document.data()["longitude"] as? Double else {
                        continue
                    }
                    
                    // Enter the dispatch group for each async operation
                    dispatchGroup.enter()
                    
                    self.fetchUserName(uid: document.documentID) { name in
                        defer {
                            dispatchGroup.leave()
                        }
                        
                        // If name is successfully fetched, add the data to locations
                        if let name = name {
                            let friendLocation = FriendLocation(latitude: latitude, longitude: longitude, documentID: document.documentID, name: name)
                            locations.append(friendLocation)
                        }
                    }
                }
                
                // Once all async operations are complete, update friendsLocations
                dispatchGroup.notify(queue: .main) {
                    self.friendsLocations = locations
                }
            }
    }

    func fetchUserName(uid: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error fetching user info for \(uid): \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("User document not found for \(uid)")
                completion(nil)
                return
            }
            
            if let data = document.data(),
               let name = data["name"] as? String {
                completion(name)  // Call completion handler with the name
            } else {
                print("User data is incomplete for \(uid)")
                completion(nil)
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

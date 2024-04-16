import Foundation
import Firebase

// Define a struct to represent a study user object
struct StudyUser: Hashable {
    var uid: String
    var name: String
    var number: String

    // Conform to the `Hashable` protocol by providing a hash function
    func hash(into hasher: inout Hasher) {
        // Hash the unique properties of the struct
        hasher.combine(uid)
        hasher.combine(name)
        hasher.combine(number)
    }

    // Implement the `==` operator for equality comparison
    static func == (lhs: StudyUser, rhs: StudyUser) -> Bool {
        return lhs.uid == rhs.uid && lhs.name == rhs.name && lhs.number == rhs.number
    }
}


final class HomePageViewModel: ObservableObject {
    @Published var toggleOffset: CGFloat = 0
    @Published var toggleOpacity: Double = 1
    @Published var isUserActive = false
    @Published var pendingRequests = [StudyUser]()
    @Published var sentInvites = [StudyUser]()
    @Published var acceptedRequests = [StudyUser]()
    @Published var displayName: String = "";
    
    private var db = Firestore.firestore()
    
    func fetchRequests() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }
        
        let userDocRef = db.collection("users").document(currentUserID)
        
        userDocRef.getDocument { [weak self] (document, error) in
            guard let self = self, let document = document, document.exists else { return }
            let data = document.data()
            
            if let invitesReceived = data?["invitesReceived"] as? [String] {
                self.getUsers(uids: invitesReceived) { users in
                    self.pendingRequests = users
                }
            }
            if let invitesSent = data?["invitesSent"] as? [String] {
                self.getUsers(uids: invitesSent) { users in
                    self.sentInvites = users
                }
            }
            if let invitesAccepted = data?["invitesAccepted"] as? [String] {
                self.getUsers(uids: invitesAccepted) { users in
                    self.acceptedRequests = users
                }
            }
        }
    }
    
    func acceptRequest(_ user: StudyUser) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }

        // Reference to the current user's document
        let currentUserDocRef = db.collection("users").document(currentUserID)
        
        // Reference to the accepted user's document (the `StudyUser`)
        let userDocRef = db.collection("users").document(user.uid)

        // Update the current user's document
        currentUserDocRef.updateData([
            "invitesReceived": FieldValue.arrayRemove([user.uid]),
            "invitesAccepted": FieldValue.arrayUnion([user.uid])
        ]) { error in
            if let error = error {
                print("Error accepting request: \(error.localizedDescription)")
            } else {
                // Add the accepted user to the acceptedRequests array
                self.acceptedRequests.append(user)
                
                // Remove the accepted user from the pendingRequests array
                if let index = self.pendingRequests.firstIndex(where: { $0.uid == user.uid }) {
                    self.pendingRequests.remove(at: index)
                }

                // Now, update the `StudyUser`'s document to remove currentUserID from their `sentInvites`
                // and add currentUserID to their `acceptedInvites`.
                userDocRef.updateData([
                    "sentInvites": FieldValue.arrayRemove([currentUserID]),
                    "acceptedInvites": FieldValue.arrayUnion([currentUserID])
                ]) { error in
                    if let error = error {
                        print("Error updating user document: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated user's sentInvites and acceptedInvites.")
                    }
                }
            }
        }
    }

    
    func denyRequest(_ user: StudyUser) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }
        
        let userDocRef = db.collection("users").document(currentUserID)
        
        userDocRef.updateData(["invitesReceived": FieldValue.arrayRemove([user.uid])]) { error in
            if let error = error {
                print("Error denying request: \(error.localizedDescription)")
            } else {
                // Remove the denied user from the pendingRequests array
                if let index = self.pendingRequests.firstIndex(where: { $0.uid == user.uid }) {
                    self.pendingRequests.remove(at: index)
                }
            }
        }
    }
    
    func updateUserActiveStatus() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }
        
        let userDocRef = db.collection("users").document(currentUserID)
        
        userDocRef.updateData(["Status": isUserActive])
    }
    
    func fetchDisplayName() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        // Fetch phone number from Firestore
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                if let phoneNumber = document.data()?["name"] as? String {
                        self.displayName = phoneNumber
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getUsers(uids: [String], completion: @escaping ([StudyUser]) -> Void) {
        var users = [StudyUser]()
        let group = DispatchGroup()
        
        for uid in uids {
            group.enter()
            let docRef = db.collection("users").document(uid)
            docRef.getDocument { (document, error) in
                defer { group.leave() }
                
                if let document = document, document.exists {
                    if let data = document.data(),
                       let name = data["name"] as? String,
                       let number = data["number"] as? String {
                        let user = StudyUser(uid: uid, name: name, number: number)
                        users.append(user)
                    }
                } else {
                    print("Document does not exist for uid: \(uid)")
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(users)
            if uids.count == 2 {
                // Call fetchSharedClasses if there are exactly two UIDs
                self.fetchSharedClasses(uidOne: uids[0], uidTwo: uids[1]) { sharedClasses in
                    // Handle shared classes here if needed
                    print("Shared Classes: \(sharedClasses)")
                }
            }
        }
    }

    
    func fetchSharedClasses(uidOne: String, uidTwo: String, completion: @escaping ([String]) -> Void) {
        var classesOne: Set<String> = []
        var classesTwo: Set<String> = []
        
        // Fetch classes for first user
        db.collection("users").document(uidOne).getDocument { document, error in
            if let error = error {
                print("Error fetching user info for \(uidOne): \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let document = document, document.exists else {
                print("User document not found for \(uidOne)")
                completion([])
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
                    completion([])
                    return
                }
                
                guard let document = document, document.exists else {
                    print("User document not found for \(uidTwo)")
                    completion([])
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
                completion(sharedClasses)
            }
        }
    }
}

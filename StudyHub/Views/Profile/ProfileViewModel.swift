import Foundation
import Firebase

final class ProfileViewModel: ObservableObject {
    private var db = Firestore.firestore()
    @Published var name: String = ""
    @Published var number: String = ""
    @Published var email: String = ""
    

    func saveProfile() {
        
        // Get the UID of the currently authenticated user
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        
        // Use UID as the document ID
        let profileRef = db.collection("users").document(uid)
        
        let data: [String: Any] = [
            "name": name,
            "number" : number
            // Add other fields if necessary
        ]
        
        profileRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile saved successfully!")
            }
        }
    }
    
    func getName() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        // Fetch name from Firestore
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                if let name = document.data()?["name"] as? String {
                        self.name = name
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getPhoneNumber() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        // Fetch phone number from Firestore
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                if let phoneNumber = document.data()?["number"] as? String {
                        self.number = phoneNumber
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func getEmail() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        }
        // Fetch phone number from Firestore
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                if let email = document.data()?["email"] as? String {
                        self.email = email
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}

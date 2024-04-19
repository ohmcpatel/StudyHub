import Foundation
import SwiftUI
import Firebase 

class CourseUpdateViewController: UIViewController, ObservableObject {
    // Properties
    let apiManager: CanvasAPIManager
    
    // Initializer
    init(baseApiUrl: String, accessToken: String, enrollmentState: String) {
        // Initialize the CanvasAPIManager
        self.apiManager = CanvasAPIManager(baseApiUrl: baseApiUrl, accessToken: accessToken, enrollmentState: enrollmentState)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call the fetchCourseData function
        self.apiManager.fetchCourseData { result in
            switch result {
            case .success(let json):
                // Handle the fetched JSON data
                // You can further process the data as required
                // For example, parse the JSON data using the parseJson function
                self.apiManager.parseJson(jsonData: json) { parseResult in
                    switch parseResult {
                    case .success(let parsedData):
                        // Handle the parsed data
                        print(self.extractCurrentClasses(from: parsedData))
                        // Use the parsed data in your view
                        // Update the UI or handle the data as needed
                    case .failure(let error):
                        // Handle the error
                        print("Failed to parse JSON data: \(error)")
                    }
                }
                
            case .failure(let error):
                // Handle the error
                print("Failed to fetch course data: \(error)")
            }
        }
    }
    
    func extractCurrentClasses(from courses: [[String: Any]]) -> [String] {
        var currentClasses: [String] = []
        
        for course in courses {
            // Check if the course dictionary contains the necessary keys
            if let name = course["name"] as? String,
               let enrollments = course["enrollments"] as? NSArray {
                // Iterate over enrollments
                for enrollment in enrollments {
                    // Convert enrollment to dictionary
                    if let enrollmentDict = enrollment as? [String: Any] {
                        // Check if the user is actively enrolled
                        if let enrollmentState = enrollmentDict["enrollment_state"] as? String,
                           enrollmentState == "active" {
                            // Add the course name to the result array if the user is actively enrolled
                            currentClasses.append(name)
                            break // Once an active enrollment is found, no need to check further enrollments for this course
                        }
                    }
                }
            }
        }
        updateCurrentCoursesField(with: currentClasses)
        return currentClasses
    }
    
    func updateCurrentCoursesField(with courses: [String]) {
        // Step 1: Extract current classes using your function
        let currentClasses = courses; 
        
        // Step 2: Get the current user's UID
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        let uid = currentUser.uid
        
        // Step 3: Get a reference to the Firestore database
        let db = Firestore.firestore()
        
        // Step 4: Update the courses field in the user's document
        db.collection("users").document(uid).updateData(["classes": currentClasses]) { error in
            if let error = error {
                print("Error updating courses field: \(error.localizedDescription)")
            } else {
                print("Courses field updated successfully for user ID \(uid).")
            }
        }
    }
    
    
}

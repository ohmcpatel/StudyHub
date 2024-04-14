import UIKit
import Firebase

class CourseUpdateViewController: UIViewController {
    private let courseService = CourseService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the CourseService method to update courses
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated.")
            return
        } // Replace with actual user UID
        
        courseService.fetchCoursesAndUpdateFirestore(for: userUID) { error in
            if let error = error {
                // Handle the error (e.g., show an alert)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Failed to update courses: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                // Handle success (e.g., show a success message)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Courses updated successfully.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

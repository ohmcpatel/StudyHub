import Foundation
import Firebase

class CourseService {
    private let db = Firestore.firestore()
    
    private let baseAPIURL = "https://canvas.instructure.com/api/v1/courses"
    private let accessToken = "1158~9vn1qUR4MIWvnnTrYtqDAcHfG0xIS9c2ao3c4iCWfBjO8rD8HyNBjV90QcUxXC45"
    private let enrollmentState = "active" // Change this value as needed
    
    // Method to fetch courses from the API and update Firestore
    func fetchCoursesAndUpdateFirestore(for userUID: String, completion: @escaping (Error?) -> Void) {
        fetchCourses { [weak self] courses, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let courses = courses else {
                completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No courses received."]))
                return
            }
            
            self?.addClassesToUserFirestore(userUID: userUID, courses: courses, completion: completion)
        }
    }
    
    // Fetch courses from the API
    private func fetchCourses(completion: @escaping ([String]?, Error?) -> Void) {
        guard let apiURL = URL(string: "\(baseAPIURL)?access_token=\(accessToken)&enrollment_state=\(enrollmentState)") else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL."]))
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        
        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected response"]))
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received."]))
                return
            }
            
            // Parse the data
            self.parseCoursesData(data: data, completion: completion)
        }
        
        // Start the URL session data task
        task.resume()
    }
    
    // Parse the courses data
    private func parseCoursesData(data: Data, completion: @escaping ([String]?, Error?) -> Void) {
        do {
            let courses = try JSONDecoder().decode([String].self, from: data)
            completion(courses, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    // Add classes to user's Firestore document
    private func addClassesToUserFirestore(userUID: String, courses: [String], completion: @escaping (Error?) -> Void) {
        let userDocRef = db.collection("users").document(userUID)
        userDocRef.updateData(["classes": courses]) { error in
            completion(error)
        }
    }
}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

struct CourseUpdateViewControllerWrapper: UIViewControllerRepresentable {
    @State private var accessToken: String?
    @State private var isFetchingApiKey = false
    @EnvironmentObject var viewModel: AuthenticationViewModel

    func makeUIViewController(context: Context) -> CourseUpdateViewController {
        // Create an instance of CourseUpdateViewController with the necessary parameters
        let baseApiUrl = "https://canvas.instructure.com/api/v1/courses"
        let accessToken = viewModel.apiKey
        
//        "1158~u2VY8aUAtxE2c3lBo2ASDgstJYav7iVVOqAHgx81TTGEtBbltBpx8SJXTj1UNPqd"
        let enrollmentState = "active" // Replace with your desired enrollment state
        
        return CourseUpdateViewController(baseApiUrl: baseApiUrl, accessToken: accessToken, enrollmentState: enrollmentState)
    }

    func updateUIViewController(_ uiViewController: CourseUpdateViewController, context: Context) {
        // No updates needed in this case
    }
}

struct SettingsView: View {
    @State private var isPresentingCourseUpdateVC = false
    @State private var apiKey: String = ""
    @State private var showAlert = false
    @EnvironmentObject var viewModel: AuthenticationViewModel

    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
            
            // Text field for the user to input their API key
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Go to Canvas, Settings, and generate a new API key. Copy and paste it here so we can fetch your classes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Enter API key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)
                
                // Save button to save the API key
                Button("Save API Key") {
                    saveApiKeyToFirestore(apiKey: apiKey)
                    viewModel.setLocalApiKey(API: apiKey)
                }
                .padding()
            }
            .padding()
            
            // Button to manually update courses
            Button("Manually Update Courses") {
                // Present the view controller when the button is tapped
                isPresentingCourseUpdateVC = true
            }
            .sheet(isPresented: $isPresentingCourseUpdateVC) {
                // Present the CourseUpdateViewController using the wrapper
                CourseUpdateViewControllerWrapper()
                Text("Your classes have been loaded!")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 100)
                
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Failed to save API key. Please try again."), dismissButton: .default(Text("OK")))
        }
    }
    
    // Function to save the API key to Firestore
    func saveApiKeyToFirestore(apiKey: String) {
        // Ensure the user is signed in
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            showAlert = true
            return
        }
        
        let uid = currentUser.uid
        
        // Reference to Firestore
        let db = Firestore.firestore()
        
        // Update the "apiKey" field in the user's document
        db.collection("users").document(uid).updateData(["apiKey": apiKey]) { error in
            if let error = error {
                print("Error updating API key: \(error.localizedDescription)")
                showAlert = true
            } else {
                print("API key updated successfully for user ID \(uid).")
            }
        }
    }
}

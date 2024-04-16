import SwiftUI

struct SettingsView: View {
    @State private var isPresentingCourseUpdateVC = false
    
    var body: some View {
        VStack {
            Text("Settings View")
            
            // Button to manually update courses
            Button("Manually Update Courses") {
                // Present the view controller when the button is tapped
                isPresentingCourseUpdateVC = true
            }
            .sheet(isPresented: $isPresentingCourseUpdateVC) {
                // Present the view controller
//                CourseUpdateViewControllerWrapper()
            }
        }
    }
}

//// Create a UIViewControllerRepresentable wrapper for the view controller
//struct CourseUpdateViewControllerWrapper: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> CourseUpdateViewController {
//        // Return an instance of your view controller
//        return CourseUpdateViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: CourseUpdateViewController, context: Context) {
//        // No updates needed in this case
//    }
//}

import Foundation
import Combine

// Define the model for an exam or assignment
struct ExamOrAssignment: Identifiable, Decodable {
    var id: String
    var name: String
    var dueDate: Date
}

// Define the model for a class and make it conform to Identifiable and Decodable
struct ClassData: Identifiable, Decodable {
    var id: String
    var className: String
    var examsAndAssignments: [ExamOrAssignment]
}

// ViewModel to manage and provide data
class ClassScheduleViewModel: ObservableObject {
    @Published var classData: [ClassData] = []
    
    // Function to fetch class data
    func fetchClassData(from jsonData: Data) {
        do {
            // Decode JSON data into an array of ClassData
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedData = try decoder.decode([ClassData].self, from: jsonData)
            
            // Update the published property
            DispatchQueue.main.async {
                self.classData = decodedData
            }
        } catch {
            print("Error decoding JSON data: \(error)")
        }
    }
    
    // Function to generate study schedule for a specific class
    func generateStudySchedule(for classData: ClassData, studyDays: Int = 3) -> [Date] {
        // Function to calculate study schedule
        func calculateStudyDates(dueDate: Date, studyDays: Int) -> [Date] {
            let interval = dueDate.timeIntervalSinceNow / Double(studyDays + 1)
            var studyDates: [Date] = []
            
            for day in 1...studyDays {
                let studyDate = Date(timeIntervalSinceNow: interval * Double(day))
                studyDates.append(studyDate)
            }
            
            return studyDates
        }
        
        // Generate and return study dates for each exam/assignment
        return calculateStudyDates(dueDate: classData.examsAndAssignments.first?.dueDate ?? Date(), studyDays: studyDays)
    }
}

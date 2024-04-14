import SwiftUI

// The SwiftUI view to display the class schedule
struct ClassScheduleView: View {
    @StateObject private var viewModel = ClassScheduleViewModel()
    
    var body: some View {
        // A list view to display class data
        List(viewModel.classData) { classData in
            VStack(alignment: .leading) {
                // Display class name
                Text("Class: \(classData.className)")
                    .font(.headline)
                
                // Display exams and assignments
                ForEach(classData.examsAndAssignments) { examOrAssignment in
                    VStack(alignment: .leading) {
                        Text("Assignment/Exam: \(examOrAssignment.name)")
                        Text("Due Date: \(examOrAssignment.dueDate, style: .date)")
                    }
                }
                
                // Generate and display study schedule for the class
                Text("Study Dates:")
                ForEach(viewModel.generateStudySchedule(for: classData), id: \.self) { studyDate in
                    Text("\(studyDate, style: .date)")
                }
            }
            .padding()
        }
        .onAppear {
            // Load JSON data (replace with your JSON data source)
            // Here we're just providing an example JSON data string
            let jsonDataString = """
            [
              {
                "id": "class1",
                "className": "Math",
                "examsAndAssignments": [
                  {
                    "id": "exam1",
                    "name": "Math Exam 1",
                    "dueDate": "2024-05-20T00:00:00Z"
                  },
                  {
                    "id": "assignment1",
                    "name": "Math Assignment 1",
                    "dueDate": "2024-04-15T00:00:00Z"
                  },
                  {
                    "id": "exam2",
                    "name": "Math Exam 2",
                    "dueDate": "2024-06-10T00:00:00Z"
                  }
                ]
              },
              {
                "id": "class2",
                "className": "History",
                "examsAndAssignments": [
                  {
                    "id": "essay1",
                    "name": "History Essay",
                    "dueDate": "2024-05-05T00:00:00Z"
                  },
                  {
                    "id": "exam3",
                    "name": "History Exam",
                    "dueDate": "2024-05-25T00:00:00Z"
                  }
                ]
              },
              {
                "id": "class3",
                "className": "Science",
                "examsAndAssignments": [
                  {
                    "id": "report1",
                    "name": "Science Lab Report",
                    "dueDate": "2024-04-20T00:00:00Z"
                  },
                  {
                    "id": "presentation1",
                    "name": "Science Presentation",
                    "dueDate": "2024-05-15T00:00:00Z"
                  }
                ]
              }
            ]
            """
            if let jsonData = jsonDataString.data(using: .utf8) {
                viewModel.fetchClassData(from: jsonData)
            }
        }
    }
}

// Preview provider for SwiftUI previews
struct ClassScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ClassScheduleView()
    }
}

import SwiftUI

// The SwiftUI view to display the class schedule
struct ClassScheduleView: View {
    @StateObject private var viewModel = ClassScheduleViewModel()
    
    var body: some View {
        // Display the class data in a list
        List {
            // Iterate over each class data
            ForEach(viewModel.classData) { classData in
                Section(header: Text(classData.className)
                            .font(.title2)
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.blue)) {
                    // Iterate over exams and assignments
                    ForEach(classData.examsAndAssignments) { examOrAssignment in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("📚")
                                    .font(.title)
                                    .padding(.trailing, 5)
                                Text(examOrAssignment.name)
                                    .font(.headline)
                            }
                            
                            HStack {
                                Text("📅")
                                    .font(.title)
                                    .padding(.trailing, 5)
                                Text("\(examOrAssignment.dueDate, style: .date)")
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // Display study schedule for the class
                    if !viewModel.generateStudySchedule(for: classData).isEmpty {
                        Text("🗓 Study Dates:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                        
                        ForEach(viewModel.generateStudySchedule(for: classData), id: \.self) { studyDate in
                            HStack {
                                Text("🕒")
                                    .font(.title)
                                    .padding(.trailing, 5)
                                Text("\(studyDate, style: .date)")
                            }
                            .padding(.vertical, 3)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.vertical, 5)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Class Schedule")
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

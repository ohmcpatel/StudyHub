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
                    "id": "class4",
                    "className": "CECS - First Year Student Success 2022",
                    "examsAndAssignments": [
                        {
                            "id": "course1",
                            "name": "Introduction to College Life",
                            "dueDate": "2024-04-25T00:00:00Z"
                        },
                        {
                            "id": "course2",
                            "name": "Career Planning",
                            "dueDate": "2024-05-10T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class5",
                    "className": "Knights Career Navigator AY' 2022-2023",
                    "examsAndAssignments": [
                        {
                            "id": "course3",
                            "name": "Career Exploration",
                            "dueDate": "2024-04-30T00:00:00Z"
                        },
                        {
                            "id": "course4",
                            "name": "Resume Workshop",
                            "dueDate": "2024-05-15T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class6",
                    "className": "Kognito at-risk for Faculty & Staff",
                    "examsAndAssignments": [
                        {
                            "id": "course5",
                            "name": "Mental Health Awareness",
                            "dueDate": "2024-04-28T00:00:00Z"
                        },
                        {
                            "id": "course6",
                            "name": "Effective Communication",
                            "dueDate": "2024-05-12T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class7",
                    "className": "Math Placement Test Fall 2022",
                    "examsAndAssignments": [
                        {
                            "id": "course7",
                            "name": "Pre-Algebra Concepts",
                            "dueDate": "2024-04-27T00:00:00Z"
                        },
                        {
                            "id": "course8",
                            "name": "Geometry and Trigonometry",
                            "dueDate": "2024-05-08T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class8",
                    "className": "Linear Algebra 2",
                    "examsAndAssignments": [
                        {
                            "id": "course9",
                            "name": "Matrix Operations",
                            "dueDate": "2024-04-25T00:00:00Z"
                        },
                        {
                            "id": "course10",
                            "name": "Vector Spaces",
                            "dueDate": "2024-05-14T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class9",
                    "className": "CECS Advising Webcourse Spring 2024",
                    "examsAndAssignments": [
                        {
                            "id": "course11",
                            "name": "Academic Advising",
                            "dueDate": "2024-04-26T00:00:00Z"
                        },
                        {
                            "id": "course12",
                            "name": "Course Planning",
                            "dueDate": "2024-05-10T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class10",
                    "className": "Computer Science Placement Exam",
                    "examsAndAssignments": [
                        {
                            "id": "course13",
                            "name": "Programming Fundamentals",
                            "dueDate": "2024-04-28T00:00:00Z"
                        },
                        {
                            "id": "course14",
                            "name": "Data Structures and Algorithms",
                            "dueDate": "2024-05-12T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class11",
                    "className": "Game Programming",
                    "examsAndAssignments": [
                        {
                            "id": "course15",
                            "name": "Unity Basics",
                            "dueDate": "2024-04-25T00:00:00Z"
                        },
                        {
                            "id": "course16",
                            "name": "Game Mechanics Design",
                            "dueDate": "2024-05-08T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class12",
                    "className": "AI",
                    "examsAndAssignments": [
                        {
                            "id": "course17",
                            "name": "Machine Learning Concepts",
                            "dueDate": "2024-04-29T00:00:00Z"
                        },
                        {
                            "id": "course18",
                            "name": "Neural Networks",
                            "dueDate": "2024-05-13T00:00:00Z"
                        }
                    ]
                },
                {
                    "id": "class13",
                    "className": "SWE",
                    "examsAndAssignments": [
                        {
                            "id": "course19",
                            "name": "Software Engineering Principles",
                            "dueDate": "2024-04-27T00:00:00Z"
                        },
                        {
                            "id": "course20",
                            "name": "Project Management in SWE",
                            "dueDate": "2024-05-12T00:00:00Z"
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

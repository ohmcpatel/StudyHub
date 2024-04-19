import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    
    @Environment(\.dismiss) var dismiss
    @State private var presentingConfirmationDialog = false

    // Custom binding for phone number formatting
    private var formattedPhoneNumberBinding: Binding<String> {
        Binding(
            get: {
                profileViewModel.number
            },
            set: { newValue in
                profileViewModel.number = formatPhoneNumber(newValue)
            }
        )
    }
    
    private func formatPhoneNumber(_ input: String) -> String {
        // Remove all non-digit characters
        let digits = input.filter { $0.isNumber }
        
        // Format the number based on length
        switch digits.count {
        case 0...3:
            return digits
        case 4...6:
            // Convert integers to String.Index
            let areaCodeEndIndex = digits.index(digits.startIndex, offsetBy: 3)
            let areaCode = digits[digits.startIndex..<areaCodeEndIndex]
            let firstPart = digits[areaCodeEndIndex...]
            return "(\(areaCode)) \(firstPart)"
        default:
            // Convert integers to String.Index
            let areaCodeEndIndex = digits.index(digits.startIndex, offsetBy: 3)
            let firstPartEndIndex = digits.index(digits.startIndex, offsetBy: 6)
            
            let areaCode = digits[digits.startIndex..<areaCodeEndIndex]
            let firstPart = digits[areaCodeEndIndex..<firstPartEndIndex]
            let secondPart = digits[firstPartEndIndex...]
            
            return "(\(areaCode)) \(firstPart)-\(secondPart)"
        }
    }


    private func deleteAccount() {
        Task {
            if await viewModel.deleteAccount() {
                dismiss()
            }
        }
    }
    
    private func signOut() {
        viewModel.signOut()
    }
    
    private func saveProfile() {
        profileViewModel.saveProfile()
    }
    
    var body: some View {
        Form {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .clipped()
                            .padding(4)
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        Spacer()
                    }
                    Button(action: {}) {
                        Text("edit")
                    }
                }
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            
            Section(header: Text("Name")) {
                TextField("Enter your name", text: $profileViewModel.name)
            }
            
            Section(header: Text("Phone Number")) {
                TextField("Enter your number", text: formattedPhoneNumberBinding)
            }
            
            Section(header: Text("Email")) {
                Text(profileViewModel.email)
            }
            
            Section {
                Button(action: saveProfile) {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(role: .cancel, action: signOut) {
                    HStack {
                        Spacer()
                        Text("Sign out")
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
                    HStack {
                        Spacer()
                        Text("Delete Account")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "\(Self.self)")
        .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                            isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel) { }
        }
        .onAppear {
            profileViewModel.getName()
            profileViewModel.getPhoneNumber()
            profileViewModel.getEmail()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}

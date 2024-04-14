import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = HomePageViewModel()
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Welcome, \(viewModel.displayName)!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        // Active status toggle section
                        VStack {
                            Text("Are you active?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Toggle(isOn: $viewModel.isUserActive) {
                                Text("Active")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .onChange(of: viewModel.isUserActive) { _ in
                                viewModel.updateUserActiveStatus()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(20)
                        
                        // Received invites section (centered)
                        if !viewModel.pendingRequests.isEmpty {
                            VStack(alignment: .center, spacing: 10) {
                                Text("Invites")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: 0xFA4A0C, opacity: 1))
                                
                                ForEach(viewModel.pendingRequests, id: \.self) { request in
                                    HStack {
                                        Text(request.name)
                                            .font(.body)
                                            .foregroundColor(.black)
                                        Spacer()
                                        
                                        // Custom checkmark button (larger size)
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                viewModel.acceptRequest(request)
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(
                                                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                                                )
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40) // Increased size
                                        }
                                        
                                        // Custom X button (larger size)
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                viewModel.denyRequest(request)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(
                                                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                                                )
                                                .clipShape(Circle())
                                                .frame(width: 40, height: 40) // Increased size
                                        }
                                    }
                                    .padding()
                                    .background(Color(hex: 0xFA4A0C, opacity: 0.5))
                                    .cornerRadius(12)
                                    .padding()
                                    .padding(.bottom, 5)
                                    .shadow(color: Color(hex: 0x9A9A9D, opacity: 0.6), radius: 3, x: 0, y: 2)
                                }
                            }
                            .frame(maxWidth: .infinity) // Center the content
                            .padding() // Padding to center the content
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(20)
                        }

                        // Sent invites section (centered)
                        if !viewModel.sentInvites.isEmpty {
                            VStack(alignment: .center, spacing: 10) {
                                Text("Sent Invites")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: 0xFA4A0C, opacity: 1))
                                
                                ForEach(viewModel.sentInvites, id: \.self) { invitee in
                                    HStack {
                                        Text(invitee.name)
                                            .font(.body)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                    .shadow(color: Color(hex: 0x9A9A9D, opacity: 0.6), radius: 3, x: 0, y: 2)
                                }
                            }
                            .frame(maxWidth: .infinity) // Center the content
                            .padding() // Padding to center the content
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(20)
                        }
                        
                        // Accepted requests section (centered)
                        if !viewModel.acceptedRequests.isEmpty {
                            VStack(alignment: .center, spacing: 10) {
                                Text("Accepted Requests (\(viewModel.acceptedRequests.count))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: 0xFA4A0C, opacity: 1))
                                
                                ForEach(viewModel.acceptedRequests, id: \.self) { accepted in
                                    HStack {
                                        Text("Contact \(accepted.name) at \n \(viewModel.formatPhoneNumber(accepted.number))")
                                            .font(.body)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .center) // Center the HStack
                                    .shadow(color: Color(hex: 0x9A9A9D, opacity: 0.6), radius: 3, x: 0, y: 2)

                                }
                            }
                            .frame(maxWidth: .infinity) // Center the content
                            .padding() // Padding to center the content
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(20)
                        }
                        
                    }
                }
            }
            Spacer()
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color(hex: 0xFA4A0C, opacity: 1), .white], startPoint: .top, endPoint: .bottom) // Epic background gradient
        )
        .accentColor(Color(hex: 0xFA4A0C, opacity: 1))
        .onAppear {
            viewModel.fetchRequests()
            viewModel.fetchDisplayName()
        }
    }
}

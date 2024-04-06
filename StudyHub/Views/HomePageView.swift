//
//  HomePageView.swift
//  
//
//  Created by Ohm Patel  on 4/5/24.
//
import SwiftUI

struct HomePageView: View {
    @State private var isUserActive = false
    @State private var pendingRequests = [
        "John Doe",
        "Jane Smith",
        "Alice Johnson"
    ]
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                // Greeting message
                Text("Hello Ohm,")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(.leading, -150)
            }
            // Active status toggle section
            VStack {
                Text("Are you active?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Toggle(isOn: $isUserActive) {
                    Text("Active")
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            
            // Pending requests section
            VStack {
                Text("Pending Requests")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                ForEach(pendingRequests, id: \.self) { request in
                    HStack {
                        Text(request)
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: {
                            // Action for accepting request
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        .padding(.trailing, 10)
                        
                        Button(action: {
                            // Action for denying request
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding()
            

        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

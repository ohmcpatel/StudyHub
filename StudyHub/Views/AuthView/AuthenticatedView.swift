//
//  AuthenticatedView.swift
//  StudyHub
//
//  Created by Ohm Patel  on 4/5/24.
//


import SwiftUI

struct GasButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(hex: 0xFA4A0C, opacity: 1))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.orange.opacity(0.5), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension AuthenticatedView where Unauthenticated == EmptyView {
  init(@ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = nil
    self.content = content
  }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
  @StateObject private var viewModel = AuthenticationViewModel()
  @State private var presentingLoginScreen = false
  @State private var presentingProfileScreen = false

  var unauthenticated: Unauthenticated?
  @ViewBuilder var content: () -> Content

  public init(unauthenticated: Unauthenticated?, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated
    self.content = content
  }

  public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
    self.unauthenticated = unauthenticated()
    self.content = content
  }


  var body: some View {
    switch viewModel.authenticationState {
    case .unauthenticated, .authenticating:
      VStack {
        if let unauthenticated {
          unauthenticated
        }
        else {
          Text("You're not logged in.")
        }
        Button("Tap here to log in") {
          viewModel.reset()
          presentingLoginScreen.toggle()
        }
      }
      .sheet(isPresented: $presentingLoginScreen) {
        AuthenticationView()
          .environmentObject(viewModel)
      }
    case .authenticated:
        VStack {
            Button("Enter Study Hub Here") {
                presentingProfileScreen.toggle()
            }
            .buttonStyle(GasButtonStyle())
        }
      .fullScreenCover(isPresented: $presentingProfileScreen) {
        NavigationView {
          HomePageViewController()
            .environmentObject(viewModel)
        }
      }
    }
  }
}

struct AuthenticatedView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticatedView {
      Text("You're signed in.")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.yellow)
    }
  }
}

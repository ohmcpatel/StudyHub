//
//  AuthenticationView.swift
//  StudyHub
//
//  Created by Ohm Patel  on 4/5/24.
//


import SwiftUI
import Combine

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel

  var body: some View {
    VStack {
      switch viewModel.flow {
      case .login:
        LoginView()
          .environmentObject(viewModel)
      case .signUp:
        SignupView()
          .environmentObject(viewModel)
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
      .environmentObject(AuthenticationViewModel())
  }
}
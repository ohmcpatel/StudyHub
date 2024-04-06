//
//  StudyHubApp.swift
//  StudyHub
//
//  Created by Ohm Patel  on 2/18/24.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct FavouritesApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      NavigationView {
        AuthenticatedView {
          Image(systemName: "book")
            .resizable()
            .frame(width: 100 , height: 100)
            .foregroundColor(Color(.orange))
            .aspectRatio(contentMode: .fit)
            .clipped()
            .padding(6)
          Text("Welcome to StudyHub!")
            .font(.title)
          Text("You need to be logged in to use this app.")
        } content: {
          Spacer()
        }
      }
    }
  }
}

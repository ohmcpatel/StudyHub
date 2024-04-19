//
//  AuthenticationViewModel.swift
//  StudyHub
//
//  Created by Ohm Patel  on 4/5/24.
//  Updated by Trever Jones on 4/8/24
//

import Foundation
import FirebaseAuth
import Firebase

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var flow: AuthenticationFlow = .login
    
    @Published var isValid  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage = ""
    @Published var user: User?
    @Published var apiKey = ""
    
    private let db = Firestore.firestore()
    
    
    init() {
        registerAuthStateHandler()
        
        $flow
            .combineLatest($email, $password, $confirmPassword)
            .map { flow, email, password, confirmPassword in
                flow == .login
                ? !(email.isEmpty || password.isEmpty)
                : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
            }
        }
    }
    
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    private func wait() async {
        do {
            print("Wait")
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func reset() {
        flow = .login
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    func sendEmailVerification() async {
        do {
            try await Auth.auth().currentUser?.sendEmailVerification()
            
        } catch {
            print("Error sending email verification: \(error.localizedDescription)")
        }
    }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
  func signInWithEmailPassword() async -> Bool {
    authenticationState = .authenticating
    do {
      try await Auth.auth().signIn(withEmail: self.email, password: self.password)
      fetchApiKey()
      return true
    }
    catch  {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signUpWithEmailPassword() async -> Bool {
    authenticationState = .authenticating
    do  {
      let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
      let userRef = db.collection("users").document(authResult.user.uid)
      let userData: [String: Any] = ["email": email]
      try await userRef.setData(userData)
      return true
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signOut() {
    do {
      try Auth.auth().signOut()
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
    }
  }

  func deleteAccount() async -> Bool {
    do {
      try await user?.delete()
      return true
    }
    catch {
      errorMessage = error.localizedDescription
      return false
    }
  }
    
    func setLocalApiKey(API: String) {
        self.apiKey = API
    }
    func fetchApiKey() {
            // Ensure the user is signed in
            guard let currentUser = Auth.auth().currentUser else {
                print("No user is currently signed in.")
                return
            }
            
            let uid = currentUser.uid
            
            // Reference to Firestore
            let db = Firestore.firestore()
            
            // Fetch the API key from the user's document
            db.collection("users").document(uid).getDocument { document, error in
                if let error = error {
                    print("Error fetching API key: \(error.localizedDescription)")
                } else if let document = document, document.exists, let data = document.data() {
                    if let fetchedApiKey = data["apiKey"] as? String {
                        self.apiKey = fetchedApiKey
                    } else {
                        print("API key not found for user ID \(uid).")
                    }
                } else {
                    print("Document does not exist for user ID \(uid).")
                }
            }
        }
    }


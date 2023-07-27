//
//  AuthViewModel.swift
//  EventLocator
//
//  Created by Kao on 2023-06-30.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var errMsg = ""
    @Published var authState: AuthState = .Unauthenticated
    @Published var addedFriend: User? // Added property for the friend being added

    
    private var handle: AuthStateDidChangeListenerHandle?
    
    var rootView: RootView {
        self.authState == .Authenticated ? .Home : .Login
    }
    
    init() {
        registerAuthStateListener()
    }
    
    func registerAuthStateListener() {
        if handle == nil {
            Task { @MainActor in
                handle = Auth.auth().addStateDidChangeListener { auth, user in
                    if let user {
                        self.authState = .Authenticated
                        self.user = user
                        print(#function, "User [email: \( String(describing: user.email) )] logged in")
                    }
                    else {
                        self.authState = .Unauthenticated
                        self.user = nil
                        print(#function, "User not logged in")
                    }
                }
            }
        }
    }
    
    @MainActor
    func register(email: String, password: String) async -> Bool {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            errMsg = ""
            return true
        } catch {
            errMsg = error.localizedDescription
            print(#function, "Error when creating a user: \(error)")
            return false
        }
    }
    
    @MainActor
    func login(email: String, password: String) async -> Bool {
        authState = .Authenticating
        
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            authState = .Authenticated
            errMsg = ""
            return true
        } catch {
            authState = .Unauthenticated
            errMsg = error.localizedDescription
            print(#function, "Error when logging in user: \(error)")
            return false
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(#function, "Error when logging out user: \(error)")
        }
    }
}

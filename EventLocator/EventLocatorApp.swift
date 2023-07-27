//
//  EventLocatorApp.swift
//  EventLocator
//
//  Created by Kao on 2023-06-29.
//

import FirebaseCore
import SwiftUI

@main
struct EventLocatorApp: App {
    private let authManager = AuthViewModel()
    @StateObject private var userProfileManager = UserProfileViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(userProfileManager)
        }
    }
}

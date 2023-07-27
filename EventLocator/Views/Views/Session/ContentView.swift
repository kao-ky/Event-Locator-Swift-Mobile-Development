//
//  ContentView.swift
//  EventLocator
//
//  Created by Kao on 2023-06-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthViewModel
    
    var body: some View {
        switch authManager.rootView {
        case .Home:
            HomeView()
        case .Login:
            LoginView()
        }
    }
}

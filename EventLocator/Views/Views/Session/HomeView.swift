//
//  HomeView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-01.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authManager: AuthViewModel
    @EnvironmentObject private var userProfileManager: UserProfileViewModel
    
    var body: some View {
        VStack {
            TabView {
                ExploreEventView()
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                    
                
                SavedEventView()
                    .tabItem {
                        Label("Saved Events", systemImage: "square.and.arrow.down")
                    }
                
                UserSearchView()
                    .tabItem {
                        Label("Search Users", systemImage: "person.badge.plus")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }

        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            UITabBar.appearance().backgroundColor = .gray
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            // preload friend list data
            Task {
                await userProfileManager.updateFriendList(email: self.authManager.user?.email)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

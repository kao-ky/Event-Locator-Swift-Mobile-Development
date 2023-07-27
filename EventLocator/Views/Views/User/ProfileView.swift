//
//  ProfileView.swift
//  EventLocator
//
//  Created by merthan karadeniz on 2023-07-10.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthViewModel
    @EnvironmentObject private var userProfileViewModel: UserProfileViewModel
    private let eventViewModel = EventViewModel.getInstance()

    @State private var nextEvent: Event?
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false

    @State var currLoginUser: User? = nil

    var body: some View {
        NavigationView {
                ZStack(alignment: .topLeading) {
                    BackgroundView()

                    VStack {
                        VStack(alignment: .leading, spacing: 8) {
                    
                            if let currLoginUser {
                                Text(currLoginUser.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            
                            Text(authManager.user?.email ?? "")
                                .font(.title3)
                                .fontWeight(.semibold)
                                
                            NavigationLink(destination: MyFriendsView()) {
                                Text("My Friends")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }

                            if let nextEvent {
                                VStack(spacing: 5) {
                                    Text("My Next Event:")
                                        .bold()
                                        .font(.title3)
                                   
                                    AsyncImage(url: URL(string: nextEvent.performers[0].image),
                                               content: { image in
                                           image.resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(maxWidth: 225, maxHeight: 225)
                                       },
                                       placeholder: {
                                           ProgressView()
                                       }
                                   )
                                    
                                    Group {
                                        Text(nextEvent.title)
                                        Text(nextEvent.dateTimeLocal.date
                                            .formatted(.dateTime
                                                .weekday(.wide)
                                                .month(.wide)
                                                .day()
                                                .year()
                                            )
                                        )
                                        Text(getEventAddress())
                                    }
                                    .offset(y: -20)
                                }
                                .padding(.top, 20)
                                .frame(maxWidth: .infinity)
                            }
                            
                            Spacer()
                            
                        }
                        
                        Spacer()

                        Button(action: authManager.logout) {
                            Text("Log out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                    .padding(20)
            }
            .onAppear(){
                Task {
                    // update user
                    let userResult = await eventViewModel.getUser(email: authManager.user?.email)
                    switch userResult {
                        case .success(let user):
                            self.currLoginUser = user
                        case .failure(let error):
                            print(#function, "Cannot obtain a value to currLoginUser: \(error)")
                    }
                }
                
                fetchNextEvent()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getEventAddress() -> String {
        guard let nextEvent else {
            return ""
        }
        
        let city = nextEvent.venue.city
        let country = nextEvent.venue.country
        
        if let address = nextEvent.venue.address {
            return "\(address), \(city), \(country)"
        }
        
        return "\(city), \(country)"
    }
    
    private func fetchNextEvent() {
        Task {
            let result = await userProfileViewModel.getNextEvent(email: self.authManager.user?.email)
            switch result {
            case .success(let event):
                self.nextEvent = event
                print(#function, "Event: \(String(describing: nextEvent))")
            case .failure(_):
                nextEvent = nil
                alertTitle = "Error"
                alertMsg = "Next events could not be loaded"
                showingAlert = true
            }
        }
    }
    
}


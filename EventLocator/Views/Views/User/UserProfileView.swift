import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var userProfileViewModel: UserProfileViewModel
    private let eventViewModel = EventViewModel.getInstance()
    
    @State private var nextEvent: Event?
    @State private var friendAttendeesList = [User]()
    
    @State private var eventCount: Int = 0
    @State private var isAdded = false

    // alert
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    @State private var isDeletionAlert = false
    
    // user
    var user: User
    @State var currLoginUser: User? = nil

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 10) {
                Text(user.name)
                    .font(.largeTitle)
                    .padding(.top, 40)
                
                Text("Attending \(eventCount) \(eventCount > 0 ? "events" : "event")")
                    .font(.headline)
                
                Button {
                    if isAdded {
                        alertTitle = "Remove Friend?"
                        alertMsg = "\(user.name) will be removed from your friend list"
                        isDeletionAlert.toggle()
                        showingAlert.toggle()
                    } else {
                        addOrRemoveFriend()
                    }
                } label: {
                    Text(isAdded ? "Remove Friend" : "Add Friend")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(isAdded ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical, 20)
                
                if userProfileViewModel.isLoading {
                    Text("Loading...")
                        .font(.headline)
                        .padding(.top, 20)
                } else {
                    
                    if let nextEvent {
                        VStack(spacing: 15) {
                            Text("Their Next Event:")
                                .font(.title)
                            
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
                            
                            if !friendAttendeesList.isEmpty && currLoginUser != nil {
                                VStack(spacing: 12) {
                                    if !(
                                            (friendAttendeesList.count == 1 && (friendAttendeesList[0] == currLoginUser! || friendAttendeesList[0] == user)
                                            ) ||
                                            
                                            (friendAttendeesList.count == 2 &&
                                                friendAttendeesList.contains(user) &&
                                                friendAttendeesList.contains(currLoginUser!)
                                            )
                                        )
                                    {
                                        Text("Your friends are also attending:")
                                            .font(.title2)
                                    }
                                    
                                    ForEach(friendAttendeesList) { attendee in
                                        if attendee.name != user.name && attendee.name != currLoginUser?.name {
                                            Text(attendee.name)
                                        }
                                    }
                                }
                                .padding(.top, 20)
                            }
                        }
                    } else {
                        Text("They have no upcoming events")
                            .font(.title2)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                // update event count
                let cntResult = await userProfileViewModel.getNumOfEvent(email: user.id)
                switch cntResult {
                    case .success(let cnt):
                        self.eventCount = cnt
                    case .failure(let error):
                        print(#function, "Cannot obtain event count of user [\(user.id)]: \(error)")
                }
                
                // update friend list
                isAdded = userProfileViewModel.friendsList.contains(user)
                
                // update user
                let userResult = await eventViewModel.getUser(email: authViewModel.user?.email)
                switch userResult {
                case .success(let user):
                    self.currLoginUser = user
                case .failure(let error):
                    print(#function, "Cannot obtain a value to currLoginUser: \(error)")
                }
            }
            
            fetchNextEventInfo()
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if isDeletionAlert {
                Button("Delete", role: .destructive) {
                    addOrRemoveFriend()
                    isDeletionAlert = false
                }
                
                Button("Cancel", role: .cancel) {
                    isDeletionAlert = false
                }
            }
            else { Button("Dismiss", role: .cancel) {} }
        } message: {
            Text(alertMsg)
        }
    }
    
    private func fetchAttendeesList() {
        Task {
            guard let nextEvent else {
                print(#function, "Error when fetching attendee list: Next event is nil")
                return
            }
            
            let attendeeResult = await userProfileViewModel.getEventAttendeeList(eventId: nextEvent.id)
            
            switch attendeeResult {
            case .success(let attendeesList):
                print(#function, "Fetched attendeesList: \(attendeesList)")
                
                friendAttendeesList = userProfileViewModel.friendsList.filter { attendeesList.contains($0) }
                    
            case .failure(let error):
                print(#function, "No attendee list fetched: \(error)")
            }
        }
    }
    
    private func addOrRemoveFriend() {
        Task {
            var isSuccessful = false
            
            if isAdded {
                isSuccessful = await userProfileViewModel.removeFriend(email: authViewModel.user?.email, friend: user)
            } else {
                isSuccessful = await userProfileViewModel.addFriend(email: authViewModel.user?.email, newFriend: user)
            }
            
            if !isSuccessful {
                alertTitle = "Error"
                alertMsg = "Operation failed"
                showingAlert.toggle()
                return
            }
            
            isAdded.toggle()
            
            if !isAdded {
                alertTitle = "Success"
                alertMsg = "User \(user.name) has been deleted from your friend list"
                showingAlert.toggle()
            }
            
            // this prompts the nav back to parent
            await userProfileViewModel.updateFriendList(email: self.authViewModel.user?.email)
        }
    }
    
    private func fetchNextEventInfo() {
        Task {
            let result = await userProfileViewModel.getNextEvent(email: user.id)
            switch result {
            case .success(let event):
                self.nextEvent = event
                print(#function, "Event: \(String(describing: nextEvent))")
                fetchAttendeesList()
                
            case .failure(_):
                nextEvent = nil
                alertTitle = "Error"
                alertMsg = "Next events could not be loaded"
                showingAlert = true
            }
        }
    }
    
    public func resetError() {
        alertMsg = ""
        alertTitle = ""
    }
    
    public func showErrorIfAny() {
        if !alertTitle.isEmpty && !alertMsg.isEmpty {
            showingAlert.toggle()
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
}

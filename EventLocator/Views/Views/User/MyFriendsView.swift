import SwiftUI

struct MyFriendsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @ObservedObject private var userSearchViewModel: UserSearchViewModel = UserSearchViewModel()
    @EnvironmentObject private var userProfileViewModel: UserProfileViewModel
    
    @State private var isFriendListLoaded = false
    @State private var navToUserProfile: String?
    @State private var listRowColor = Color.yellow
    @State private var user: User?
    
    // alert
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    @State private var isDeletionAlert = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            if isFriendListLoaded {
                if userProfileViewModel.friendsList.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("No friends in your friend list")
                            .bold()
                    }
                }
                else {
                    List {
                        ForEach(userProfileViewModel.friendsList) { user in
                            HStack {
                                Text(user.name)
                                    .font(.headline)
                                
                                NavigationLink(destination: UserProfileView(user: user)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                Spacer()
                                
                                Button {
                                    // use tap gesture to define action so that the listrow does not execute both actions
                                } label: {
                                    Text("Remove")
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .background(.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .onTapGesture {
                                    self.user = user
                                    alertTitle = "Remove Friend?"
                                    alertMsg = "\(user.name) will be removed from your friend list"
                                    isDeletionAlert.toggle()
                                    showingAlert.toggle()
                                }
                            }
                            .padding(.vertical, 3)
                        }
                        .listRowBackground(listRowColor)
                    }
                    .listStyle(GroupedListStyle())
                    .scrollContentBackground(.hidden)
                }
            }// isFriendListLoaded
            else {
                VStack {
                    ProgressView()
                    Text("Loading friend list...")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("My Friends")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            getFriendList()
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            if isDeletionAlert {
                Button("Delete", role: .destructive) {
                    if let user = self.user {
                        removeFriend(user: user)
                    }
                    isDeletionAlert = false
                }
                Button("Cancel", role: .cancel) {
                    self.user = nil
                    isDeletionAlert = false
                }
            }
            else { Button("Dismiss", role: .cancel) {} }
        } message: {
            Text(alertMsg)
        }
    }
    
    private func getFriendList() {
        Task {
            isFriendListLoaded = false
            if await !userProfileViewModel.updateFriendList(email: self.authViewModel.user?.email) {
                alertTitle = "Error"
                alertMsg = "Friend list could not be loaded"
                showingAlert.toggle()
            }
            isFriendListLoaded = true
        }
    }

    private func removeFriend(user: User) {
        Task {
            if await !userProfileViewModel.removeFriend(email: self.authViewModel.user?.email, friend: user) {
                alertTitle = "Error"
                alertMsg = "Unable to delete friend (\(user.name))"
                showingAlert.toggle()
                return
            }
            
            if let index = userProfileViewModel.friendsList.firstIndex(of: user) {
                userProfileViewModel.friendsList.remove(at: index)
                alertTitle = "Success"
                alertMsg = "Friend \(user.name) removed"
                showingAlert.toggle()
            }
        }
    }
}



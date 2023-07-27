import SwiftUI

struct UserSearchView: View {
    @State private var searchText = ""
    @ObservedObject private var userSearchViewModel = UserSearchViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var selectedUser: User? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                VStack {
                    if userSearchViewModel.users.isEmpty {
                        Text("No users found")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else {
                        List(userSearchViewModel.users) { user in
                            Button(action: {
                                selectedUser = user
                            }) {
                                Text(user.name)
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                            .listRowBackground(Color.yellow)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Search Users")
        }
        .searchable(
            text: $searchText,
            prompt: Text("Search users")
        )
        .autocorrectionDisabled(true)
        .sheet(item: $selectedUser) { user in
            UserProfileView(user: user)
        } // TODO look later nav link 
        .onChange(of: searchText) { text in
            guard let currentUserEmail = authViewModel.user?.email else {
                return
            }
            
            userSearchViewModel.searchUsers(name: searchText, currentUserEmail: currentUserEmail) { result in
                switch result {
                case .success(let users):
                    // Handle success
                    print("Found users: \(users)")
                case .failure(let error):
                    // Handle error
                    print("Error searching users: \(error)")
                }
            }
        }
    }
}

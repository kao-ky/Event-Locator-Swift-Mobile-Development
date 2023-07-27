//
//  UserSearchViewModel.swift
//  EventLocator
//
//  Created by merthan karadeniz on 2023-07-08.
//

import FirebaseFirestore
import Foundation

class UserSearchViewModel: ObservableObject {
    @Published var users: [User] = []
    private let db = Firestore.firestore()
    
    func searchUsers(name: String?, currentUserEmail: String, completion: @escaping (Result<[User], Error>) -> Void) {
        guard let name = name, !name.isEmpty else {
            // Empty search query
            self.users = []
            return
        }
        
        db.collection("Users")
            .whereField("name", isGreaterThanOrEqualTo: name)
            .whereField("name", isLessThanOrEqualTo: name + "\u{f8ff}")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    // Handle error
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    // No users found
                    self?.users = []
                    completion(.success([]))
                    return
                }
                
                let users = documents.compactMap { document -> User? in
                    let data = document.data()
                    guard let name = data["name"] as? String else { return nil }
                    return User(id: document.documentID, name: name)
                }
                
                // Filter out the current user from the search results
                let filteredUsers = users.filter { $0.id != currentUserEmail }
                
                // Update the users array and invoke completion with the results
                self?.users = filteredUsers
                completion(.success(filteredUsers))
            }
    }
}

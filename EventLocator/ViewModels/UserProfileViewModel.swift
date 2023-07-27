// UserProfileViewModel.swift

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class UserProfileViewModel: ObservableObject {
    private let db = Firestore.firestore()
//    @Published var numEvents: Int = 0
    @Published var nextEvent: Event? = nil
    @Published var friendsList: [User] = []
    @Published var isLoading: Bool = false
    
    // collections
    private let COLLECTION_USER = "Users"
    private let COLLECTION_FRIEND = "Friends"
    private let COLLECTION_EVENTS = "Events"
    
    @MainActor
    func getEventAttendeeList(eventId: Int) async -> Result<[User], Error> {
        do {
            let snapshot = try await db
                                    .collection(COLLECTION_EVENTS)
                                    .document(eventId.description)
                                    .collection(COLLECTION_USER)
                                    .getDocuments()
            let documents = snapshot.documents
            print(#function, "Retrieved event attendee list (eventId=\(eventId))")
            return .success(documents.compactMap({ try? $0.data(as: User.self) }))
        } catch {
            print(#function, "Error when retrieving event attendee list of event [id=\(eventId)]: \(error)")
            return .failure(error)
        }
    }
    
    @MainActor
    func getNumOfEvent(email: String?) async -> Result<Int, Error> {
        guard let email else {
            print(#function, "Error when fetching event: User email is nil")
            return .failure(DBError.EmailIsNil)
        }
        
        do {
            let snapshot = try await db
                                    .collection(COLLECTION_USER)
                                    .document(email)
                                    .collection(COLLECTION_EVENTS)
                                    .getDocuments()

            let documents = snapshot.documents.count
            print(#function, "Retrieved count [cnt=\(documents)] of attending events from user [email=\(email)]")
            return .success(documents)
        } catch {
            print(#function, "Error when retrieving count of attending events from user [email=\(email)]: \(error)")
            return .failure(error)
        }
    }
    
    @MainActor
    func getNextEvent(email: String?) async -> Result<Event?, Error> {
        guard let email else {
            print(#function, "Error when fetching event: User email is nil")
            return .failure(DBError.EmailIsNil)
        }
        
        do {
            let snapshot = try await db
                                    .collection(COLLECTION_USER)
                                    .document(email)
                                    .collection(COLLECTION_EVENTS)
                                    .order(by: "datetime_local", descending: false)
                                    .limit(to: 1)
                                    .getDocuments()

            let documents = snapshot.documents
            let nextEvent = documents.compactMap({ try? $0.data(as: Event.self) }).first
            print(#function, "Retrieved the most upcoming event [email=\(email)]")
            return .success(nextEvent)
        } catch {
            print(#function, "Error when retrieving the most upcoming event [email=\(email)]: \(error)")
            return .failure(error)
        }
    }
    
    @MainActor
    func addFriend(email: String?, newFriend: User) async -> Bool {
        var isSuccessful = false
        
        guard let email else {
            print(#function, "Error when adding user [id=\(newFriend.id)] as friend: User email is nil")
            return isSuccessful
        }
        
        do {
            try db
                .collection(COLLECTION_USER)
                .document(email)
                .collection(COLLECTION_FRIEND)
                .document(newFriend.id)
                .setData(from: newFriend)
            
            isSuccessful = true
            print(#function, "Success")
            
        } catch {
            
            print(#function, "Error: \(error)")
        }
        
        return isSuccessful
    }
    
    @MainActor
    func removeFriend(email: String?, friend: User) async -> Bool {
        var isSuccessful = false
        
        guard let email else {
            print(#function, "Error when deleting friend [User id=\(friend.id)] : User email is nil")
            return isSuccessful
        }
        
        do {
            try await db
                .collection(COLLECTION_USER)
                .document(email)
                .collection(COLLECTION_FRIEND)
                .document(friend.id)
                .delete()
            
            isSuccessful = true
            print(#function, "Friend [id=\(friend.id)] was deleted from User documentId=[\(email)]")
        } catch {
            print(#function, "Error when deleting friend [id=\(friend.id)] from User documentId=[\(email)]. Error: \(error)")
        }
        
        return isSuccessful
    }
    
    @MainActor
    func getFriendList(email: String?) async -> Result<[User], Error> {
        guard let email else {
            print(#function, "Error when fetching user's friend list: User email is nil")
            return .failure(DBError.EmailIsNil)
        }
        
        do {
            let snapshot = try await db
                .collection(COLLECTION_USER)
                .document(email)
                .collection(COLLECTION_FRIEND)
                .getDocuments()
            let documents = snapshot.documents
            print(#function, "Retrieved friend list of user [email=\(email)]")
            return .success(documents.compactMap({ try? $0.data(as: User.self) }))
        } catch {
            print(#function, "Error when retrieving friend list of user [email=\(email)]: \(error)")
            return .failure(error)
        }
    }
    
    @MainActor
    func updateFriendList(email: String?) async -> Bool {
        var isSuccessful = false
        
        let result = await self.getFriendList(email: email)
        switch result {
            case .success(let list):
                self.friendsList = list
                print(#function, self.friendsList)
                isSuccessful = true
            case .failure(_):
                self.friendsList = []
        }
        
        return isSuccessful
    }
}

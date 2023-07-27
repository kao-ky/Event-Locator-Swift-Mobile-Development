//
//  EventViewModel.swift
//  EventLocator
//
//  Created by Kao on 2023-06-30.
//

import FirebaseFirestore
import Foundation

@MainActor
class EventViewModel {
    
    // collections
    private let COLLECTION_USER = "Users"
    private let COLLECTION_EVENT = "Events"
    
    private let FIELD_NAME = "name"
    private let FIELD_IMAGE = "image"
    private let FIELD_EVENT_ID = "id"
    private let FIELD_ID = "id"
    
    // singleton
    
    private let db: Firestore
    private static var shared: EventViewModel?
    
    private init() {
        self.db = Firestore.firestore()
    }
    
    static func getInstance() -> EventViewModel {
        if shared == nil {
            shared = EventViewModel()
        }
        
        return self.shared!
    }
    
    // CRUD
    @MainActor
    func addUserInfo(withEmail email: String, name: String) async -> Bool {
        var isSuccessful = false
        
        do {
            try await db
                .collection(COLLECTION_USER)
                .document(email)
                .setData([
                    FIELD_NAME: name,
                    FIELD_ID: email
                ])
            
            isSuccessful = true
            print(#function, "Name=\(name) was added to documentId=[\(email)]")
        } catch {
            print(#function, "Error when adding name=\(name) to documentId=[\(email)]")
        }
        
        return isSuccessful
    }
    
    @MainActor
    func addOrRemoveEvent(email: String?, event: Event, isAttending isAdded: Bool) async -> Bool {
        var isSuccessful = false
        
        guard let email else {
            print(#function, "Error when adding event [id=\(event.id)]: User email is nil")
            return isSuccessful
        }

        do {
            let doc = db
                .collection(COLLECTION_USER)
                .document(email)
                .collection(COLLECTION_EVENT)
                .document(event.id.description)
            
            if !isAdded {
                // add if not attended yet
                try doc.setData(from: event)
            } else {
                try await doc.delete()
            }

            let userResult = await getUser(email: email)
            switch userResult {
                case .success(let user):
                    await addOrRemoveEventAttendee(email: email, user: user, event: event, isAdding: !isAdded)
                case .failure(let error):
                    print(#function, "getUser failure: \(error)")
            }
                        
            isSuccessful = true
            print(#function, "Event [id=\(event.id)] is \(isAdded ? "deleted from" : "added to") documentId=[\(email)]")
        } catch {
            print(#function, "Error when \(isAdded ? "deleting" : "adding") event [id=\(event.id)] in documentId=[\(email)]. Error: \(error)")
        }
        
        return isSuccessful
    }
    
    @MainActor
    func getUser(email: String?) async -> Result<User, Error> {
        
        guard let email else {
            print(#function, "Error when getting user: User email is nil")
            return .failure(DBError.EmailIsNil)
        }

        do {
            let snapshot = try await db
                                    .collection(COLLECTION_USER)
                                    .document(email)
                                    .getDocument()
            
            let user = try snapshot.data(as: User.self)
            print(#function, "Retrieved user: \(user)")
            return .success(user)
        } catch {
            print(#function, "Error when retrieving user [email=\(email)]: \(error)")
            return .failure(error)
        }
    }
    
    @MainActor
    func addOrRemoveEventAttendee(email: String?, user: User, event: Event, isAdding: Bool) async -> Bool {
        var isSuccessful = false
        
        guard let email else {
            print(#function, "Error when adding event [id=\(event.id)]: User email is nil")
            return isSuccessful
        }

        do {
            let doc = db
                .collection(COLLECTION_EVENT)
                .document(event.id.description)
                .collection(COLLECTION_USER)
                .document(user.id)
            
            if isAdding {
                try doc.setData(from: user)
            } else {
                try await doc.delete()
            }

            isSuccessful = true
            print(#function, "Event Attendee [email=\(email)] was \(isAdding ? "deleted from" : "added to") documentId=[\(event.id)]")
        } catch {
            print(#function, "Error when \(isAdding ? "deleting" : "adding") user [email=\(email)] in documentId=[\(event.id)]. Error: \(error)")
        }
        
        return isSuccessful
    }
    
    @MainActor
    func getEventList(email: String?) async -> Result<[Event], Error> {
        guard let email else {
            print(#function, "Error when fetching user list: User email is nil")
            return .failure(DBError.EmailIsNil)
        }
        
        do {
            let snapshot = try await db
                                    .collection(COLLECTION_USER)
                                    .document(email)
                                    .collection(COLLECTION_EVENT)
                                    .getDocuments()
            let documents = snapshot.documents
            print(#function, "Retrieved event list of user [email=\(email)]")
            return .success(documents.compactMap({ try? $0.data(as: Event.self) }))
        } catch {
            print(#function, "Error when retrieving event list of user [email=\(email)]: \(error)")
            return .failure(error)
        }
    }
    
    // can be deleted if using published savedEventList. See comments in SavedEventView OnChange()
    @MainActor
    func isEventSaved(email: String?, eventId: Int) async throws -> Bool {
        guard let email else {
            print(#function, "Error when fetching event list: User email is nil")
            throw DBError.EmailIsNil
        }
        
        do {
            let snapshot = try await db
                                    .collection(COLLECTION_USER)
                                    .document(email)
                                    .collection(COLLECTION_EVENT)
                                    .whereField(FIELD_EVENT_ID, isEqualTo: eventId)
                                    .getDocuments()
            let documents = snapshot.documents
            
            print(documents)
            // there should be only one document as each eventId is unique
            if documents.first != nil {
                print(#function, "Event is saved in User [email=\(email)]")
                return true
            }
            else {
                // no document
                print(#function, "Event is not saved in User [email=\(email)]")
                return false
            }
        }//do
    }// is event saved
}

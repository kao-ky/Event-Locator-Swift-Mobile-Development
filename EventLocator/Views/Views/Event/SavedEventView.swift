//
//  SavedEventView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-01.
//

import SwiftUI

struct SavedEventView: View {
    @EnvironmentObject private var authManager: AuthViewModel
    private let eventManager = EventViewModel.getInstance()
    
    @State private var eventList = [Event]()
    @State private var navigatedToEvent: Int?
    @State private var isEventListLoaded = false
    private let listRowColour = Color.clear
    
    // alert
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                VStack {
                    if isEventListLoaded {
                        if self.eventList.isEmpty {
                            VStack {
                                Image(systemName: "questionmark.diamond")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                Text("No saved attending events")
                                    .bold()
                                    .offset(y: -5)
                            }
                            .offset(y: -20)
                        }
                        else {
                            List {
                                ForEach(eventList) { event in
                                    NavigationLink(destination: EventDetailView(event: event), tag: event.id, selection: $navigatedToEvent) {
                                        EventListRowView(event: event)
                                    }
                                    .listRowBackground(listRowColour)
                                }
                                .onDelete(perform: deleteEvent)
                            }
                            .scrollContentBackground(.hidden)
                            .toolbar {
                                Button("Remove All") {
                                    deleteAllEvents()
                                }
                            }
                        }
                    }
                    else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Saved Events")
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
        .onAppear {
            retrieveEventList()
        }
        // onChange() remains user on the event detail view upon pressing "unattend", allowing to attend again without dismissing the view.
        // More responsively, publish an event list and pass down eventManager as EnvironmentObject.
        // This allows instant update on Saved Events through dismissing the view as the Event object is removed from the published array.
        .onChange(of: navigatedToEvent) { _ in
            if navigatedToEvent == nil {
                retrieveEventList()
            }
        }
    }
    
    private func retrieveEventList() {
        Task {
            isEventListLoaded = false
            let result = await eventManager.getEventList(email: self.authManager.user?.email)
            switch result {
            case .success(let list):
                eventList = list
            case .failure(_):
                eventList = []
                alertTitle = "Error"
                alertMsg = "Attending events could not be loaded"
            }
            
            showErrorIfAny()
            resetError()
            isEventListLoaded = true
        }
    }
    
    private func deleteEvent(offsets: IndexSet) {
        for i in offsets {
            let event = eventList[i]
            Task {
                if await !eventManager.addOrRemoveEvent(email: self.authManager.user?.email,
                                                 event: event,
                                                     isAttending: true) {
                    alertTitle = "Error"
                    alertMsg = "Unable to delete this event"
                }
            }
        }
        
        showErrorIfAny()
        resetError()
        retrieveEventList()
    }
    
    private func deleteAllEvents() {
        Task {
            for event in eventList {
                if await !eventManager.addOrRemoveEvent(email: self.authManager.user?.email,
                                                 event: event,
                                                     isAttending: true) {
                    alertTitle = "Error"
                    alertMsg = "Unable to delete all events"
                }
            }
            
            showErrorIfAny()
            resetError()
            retrieveEventList()
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
}

struct SavedEventView_Previews: PreviewProvider {
    static var previews: some View {
        SavedEventView()
    }
}

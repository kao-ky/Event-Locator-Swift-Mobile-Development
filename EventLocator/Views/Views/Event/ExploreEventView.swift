//
//  ExploreEventView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-01.
//

import SwiftUI
import CoreLocation

struct ExploreEventView: View {
    private let listRowColour = Color.clear
    let apiService = EventAPIService()
    
    @State private var locationManager = LocationViewModel()
    @State private var eventList = [Event]()
    @State private var isEventListLoaded = false
    @State private var isFirstUpdate = true

    // alert
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                if isEventListLoaded {
                    if !eventList.isEmpty {
                        List(eventList) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventListRowView(event: event)
                            }
                            .listRowBackground(listRowColour)
                            
                        }
                        .scrollContentBackground(.hidden)
                    }
                    else {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .frame(width: 40, height: 40)
                            Text("No events in the nearby area")
                                .bold()
                            Button(action: updateList) {
                                Text("Tap to retry")
                                    .padding(.vertical, 15)
                            }
                        }
                        .offset(y: -20)
                    }
                }
                else {
                    ProgressView()
                }
            }
            .navigationTitle("Explore Events")
        }
        .onAppear {
            // Avoid calling and showing unexpected list result before location enabled
            // for map-viewing events mode implementation, else can use "if location exists, then update in body"
            if !isFirstUpdate {
                updateList()
            }
        }
        .onReceive(locationManager.$lastKnownLocation) { location in
            if location != nil && isFirstUpdate {
                isFirstUpdate = false
                updateList()
            }
        }
        .refreshable { updateList() }
        .searchable(text: $searchText,
                    prompt: Text("Search by city")
        )
        .autocorrectionDisabled(true)
        .onChange(of: searchText) { _ in updateList() }
        .onSubmit(of: .search) { updateList() }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Retry") {
                updateList()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
    }
    
    func updateList() {
        Task {
            isEventListLoaded = false
            var location: CLLocation?
            
            do {
                if searchText.isEmpty {
                    location = self.locationManager.lastKnownLocation
                    print(#function, location ?? "User location is nil")
                }
                else {
                    location = await locationManager.forwardGeocoding(address: self.searchText)
                    print(#function, location ?? "Geocoded location is nil")
                }
                
                self.eventList = try await apiService.fetchEventsFromLocation(location)
                print(#function, "Event list updated")
            } catch {
                print(#function, error)
                self.eventList = []
                if searchText.isEmpty {
                    alertTitle = "Error"
                    alertMsg = "Failed to retrieve events"
                    showingAlert.toggle()
                }
            }
            
            isEventListLoaded = true
        }
    }
}

struct ExploreEventView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreEventView()
    }
}

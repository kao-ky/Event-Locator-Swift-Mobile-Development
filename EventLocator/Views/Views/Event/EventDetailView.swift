//
//  EventDetailView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-05.
//

import MapKit
import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var authManager: AuthViewModel
    private let eventManager = EventViewModel.getInstance()
    let event: Event
    
    @Environment(\.dismiss) var dismiss
    @State private var images = [String]()
    @State private var strPerformers = ""
    @State private var hasNotInit = false
    @State var isAttending = false
    
    // UI size control
    let logoWidth = 30.0
    let logoHeight = 30.0
    let dataRowHorizontalSpacing = 15.0
    
    // alert
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                EventImageView(images: images)
                    .frame(height: 250)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(event.title)
                        .font(.title)
                        .bold()
                    
                    SingleDataRowView(
                        spacing: dataRowHorizontalSpacing,
                        systemName: "person.circle",
                        logoWidth: logoWidth,
                        logoHeight: logoHeight,
                        text: strPerformers
                    )
                    
                    SingleDataRowView(
                        spacing: dataRowHorizontalSpacing,
                        systemName: "play.square",
                        logoWidth: logoWidth,
                        logoHeight: logoHeight,
                        text: event.type.capitalized
                    )
                    
                    DualDataRowView(
                        spacing: dataRowHorizontalSpacing,
                        systemName: "calendar",
                        logoWidth: logoWidth,
                        logoHeight: logoHeight,
                        topText: event.dateTimeLocal.date
                                    .formatted(.dateTime
                                        .weekday(.wide)
                                        .month(.wide)
                                        .day()
                                        .year()
                                    ),
                        bottomText: event.dateTimeLocal.date
                                    .formatted(.dateTime
                                        .hour()
                                        .minute()
                                    )
                    )
                    
                    if let lowestPrice = event.stats.lowestPrice,
                        let highestPrice = event.stats.highestPrice {
                        
                        SingleDataRowView(
                            spacing: dataRowHorizontalSpacing,
                            systemName: "dollarsign.square",
                            logoWidth: logoWidth,
                            logoHeight: logoHeight,
                            text: "$\(lowestPrice.formatted()) ~ $\(highestPrice.formatted())"
                        )
                    }
                    
                    DualDataRowView(
                        spacing: dataRowHorizontalSpacing,
                        systemName: "mappin.circle",
                        logoWidth: logoWidth,
                        logoHeight: logoHeight,
                        topText: event.venue.name,
                        bottomText: getEventAddress()
                    )
                    
                    MapView(venue: event.venue.name,
                            coordinate: CLLocationCoordinate2D(latitude: event.venue.location.lat,
                                                               longitude: event.venue.location.lon)
                    )
                    .frame(height: 250)
                    
                    
                    Button {
                        updateAttentionStatus()
                    } label: {
                        Text(isAttending ? "Unattend" : "Attend")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(isAttending ? .red : Color.primary)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
            }
        }
        .navigationTitle("Event Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    CustomNavBackButtonView("Explore")
                }
            }
        }
        .onAppear {
            isAttendingEvent(eventId: event.id)
            
            if !hasNotInit {
                var strArrPerformers = [String]()
                
                // setup image
                for performer in event.performers {
                    images.append(performer.image)
                    
                    // Additional photos of performers' from SeakGeek API calls
                    if let genres = performer.genres {
                        for genre in genres {
                            images.append(genre.image)
                        }
                    }
                    
                    // setup name in array
                    strArrPerformers.append(performer.name)
                }
                
                // name displayed directly in TextView
                strPerformers = strArrPerformers.joined(separator: ", ")
                hasNotInit = true
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text(alertMsg)
        }
    }
    
    // As the SeatGeek API returns String? on address, formatting the location by a function enhances readability
    private func getEventAddress() -> String {
        let city = event.venue.city
        let country = event.venue.country
        
        if let address = event.venue.address {
            return "\(address), \(city), \(country)"
        }
        
        return "\(city), \(country)"
    }
    
    private func updateAttentionStatus() {
        Task {
            if await !eventManager.addOrRemoveEvent(email: self.authManager.user?.email,
                                                 event: self.event,
                                                 isAttending: self.isAttending) {
                alertTitle = "Error"
                alertMsg = "Unable to save data"
                showingAlert.toggle()
                return
            }
            
            isAttending.toggle()
        }
    }
    
    private func isAttendingEvent(eventId: Int) {
        Task {
            do {
                print(event.id)
                isAttending = try await eventManager.isEventSaved(email: self.authManager.user?.email, eventId: eventId)
            } catch {
                self.alertTitle = "Error"
                self.alertMsg = "Failed to obtain event attending status"
                self.showingAlert.toggle()
                
                isAttending = false
            }
        }
    }
}

//struct EventDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let event = Event()                 // requires initialisation for preview
//        EventDetailView(event: event)
//    }
//}

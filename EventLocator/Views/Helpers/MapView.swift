//
//  MapView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-06.
//

import MapKit
import SwiftUI

struct MapView: View {
    var venue: String
    var coordinate: CLLocationCoordinate2D
    
    @State private var region: MKCoordinateRegion
    
    init(venue: String, coordinate: CLLocationCoordinate2D) {
        self.venue = venue
        self.coordinate = coordinate
        _region = State(
            initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        )
    }
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [EventLocation(name: venue, coordinate: coordinate)]) { location in
            MapMarker(coordinate: location.coordinate)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let venue = "Montreal, QC"
        let coordinate = CLLocationCoordinate2D(latitude: 45.5019, longitude: -73.5674)
        MapView(venue: venue, coordinate: coordinate)
    }
}

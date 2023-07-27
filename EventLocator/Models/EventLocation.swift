//
//  EventLocation.swift
//  EventLocator
//
//  Created by Kao on 2023-07-06.
//

import CoreLocation
import Foundation

struct EventLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

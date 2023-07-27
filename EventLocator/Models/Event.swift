//
//  Event.swift
//  EventLocator
//
//  Created by Kao on 2023-07-03.
//

import CoreLocation
import Foundation
import FirebaseFirestoreSwift

struct EventsAPIResult: Codable {
    var events: [Event]
}

struct Event: Codable, Identifiable {
    let id: Int
    let title: String
    let type: String
    let performers: [Performer]
    let venue: Venue
    let dateTimeLocal: String
    let stats: EventStats
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case type
        case performers
        case venue
        case dateTimeLocal = "datetime_local"
        case stats
    }
}

struct Venue: Codable {
    let name: String
    let address: String?
    let city: String
    let country: String
    let location: Location
    
    enum CodingKeys: String, CodingKey {
        case name
        case address
        case city
        case country
        case location
    }
}

struct Location: Codable {
    let lat: Double
    let lon: Double
}

struct Performer: Codable {
    let name: String
    let image: String
    let genres: [Genre]?
}

struct Genre: Codable {
    let image: String
}

struct EventStats: Codable {
    let lowestPrice: Double?
    let highestPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case lowestPrice = "lowest_price"
        case highestPrice = "highest_price"
    }
}

//
//  EventAPIService.swift
//  EventLocator
//
//  Created by Kao on 2023-07-03.
//

import CoreLocation
import Foundation

class EventAPIService {
    private let baseURL = "https://api.seatgeek.com/"
    private let apiKey = "MzQ2ODQwMjh8MTY4ODM3MjYxMi40OTA1Mjc0"
//    private let secret = "ad6d0574347c8daec00e8703b2287b57f8ba26720838743cf07aeb5570644771"
    
    func fetchEventsFromLocation(_ location: CLLocation?) async throws -> [Event] {
        let lat = location?.coordinate.latitude.description ?? ""
        let lon = location?.coordinate.longitude.description ?? ""
        
        let path = "2/events?lat=\(lat)&lon=\(lon)&client_id="
        
        let apiUrl = URL(string: baseURL + path + apiKey)!
        print(#function, "Fetching events from URL: \(apiUrl)")

        let request = URLRequest(url: apiUrl)
        let (data, _) = try await URLSession.shared.data(for: request)
        let result = try JSONDecoder().decode(EventsAPIResult.self, from: data)
        
        return result.events
    }
}

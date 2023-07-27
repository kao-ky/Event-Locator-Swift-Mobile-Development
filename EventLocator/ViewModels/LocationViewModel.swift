//
//  LocationViewModel.swift
//  EventLocator
//
//  Created by Kao on 2023-07-06.
//

import Foundation
import CoreLocation

class LocationViewModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    private let locationManager = CLLocationManager()
    
    @Published var lastKnownLocation: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    
    var authStatus: String {
        guard let locationStatus else {
            return "unknown"
        }
        
        switch locationStatus {
            case .authorizedAlways:
                return "authorizedAlways"
            case .authorizedWhenInUse:
                return "authorizedWhenInUse"
            case .notDetermined:
                return "notDetermined"
            case .denied:
                return "denied"
            case .restricted:
                return "restricted"
            default:
                return "unknown"
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = locationManager.authorizationStatus
        print(#function, authStatus)
        
        if locationStatus == .authorizedAlways || locationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location
        print(#function, lastKnownLocation!.coordinate)
    }
    
    // Geocoding
    @MainActor
    func forwardGeocoding(address: String) async -> CLLocation? {
        let geocoder = CLGeocoder()
        var location: CLLocation?
        
        do {
            guard let place = try await geocoder.geocodeAddressString(address).first else {
                print(#function, "Geocode not found")
                return location
            }
            
            location = place.location
        } catch {
            print(#function, "Error when geocoding address [\(address)]: \(error)")
        }
        
        return location
    }
}

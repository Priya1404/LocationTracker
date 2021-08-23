//
//  LocationManager.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation
import CoreLocation

class LocationManager {
    
    //MARK:- Singletoninstance
    static var sharedInstance = LocationManager()
    private init() {
    }
    
    //MARK:- Properties
    let locationManager = CLLocationManager()
    
}

//
//  LocationStatusInit.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation

enum LocationStatusParamKeyValues: String {
    case latitude
    case longitude
    case name
    case address
    case accuracy
    case provider
    case timestamp
    case speed
    case direction
    case distance
    case isGPSEnabled
    case type
    case isValid
}

class LocationStatusInit: Codable{
    var lat: Int
    var lng: Int
    var name: String?
    var address: String?
    var accuracy: Int?
    var provider: String?
    var timestamp: Int?
    var speed: Int?
    var direction: Int?
    var distance: Int?
    var gpsEnabled: Bool?
    var type: String?
    var valid: Bool?
    
    init(locationObject: [String: AnyObject]) {
        lat = locationObject[LocationStatusParamKeyValues.latitude.rawValue] as? Int ?? 0
        lng = locationObject[LocationStatusParamKeyValues.longitude.rawValue] as? Int ?? 0
        name = locationObject[LocationStatusParamKeyValues.name.rawValue] as? String
        address = locationObject[LocationStatusParamKeyValues.address.rawValue] as? String
        accuracy = locationObject[LocationStatusParamKeyValues.accuracy.rawValue] as? Int
        provider = locationObject[LocationStatusParamKeyValues.provider.rawValue] as? String
        timestamp = locationObject[LocationStatusParamKeyValues.timestamp.rawValue] as? Int
        speed = locationObject[LocationStatusParamKeyValues.speed.rawValue] as? Int
        direction = locationObject[LocationStatusParamKeyValues.direction.rawValue] as? Int
        distance = locationObject[LocationStatusParamKeyValues.distance.rawValue] as? Int
        gpsEnabled = locationObject[LocationStatusParamKeyValues.isGPSEnabled.rawValue] as? Bool
        type = locationObject[LocationStatusParamKeyValues.type.rawValue] as? String
        valid = locationObject[LocationStatusParamKeyValues.isValid.rawValue] as? Bool
    }
}

extension LocationStatusInit{
    var dictionary: [String: AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyObject] }
    }
}

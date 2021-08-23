//
//  LocationPostInit.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation

class LocationPostInit: Codable {
    var location: LocationStatusInit
    var batteryStatus: BatteryStatusInit
    
    init(locationObject: LocationStatusInit, batteryStatusObject: BatteryStatusInit?) {
        location = locationObject
        batteryStatus = batteryStatusObject ?? BatteryStatusInit(batteryObject: [:])
    }
}

extension LocationPostInit{
    var dictionary: [String: AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyObject] }
    }
}

//
//  BatteryStatusInit.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation

enum BatteryStatusParamKeyValues : String {
    case charge
    case expectedLife
    case chargingStatus
    case timestamp
}

//Allowed Values: PLUGGED_USB, PLUGGED_AC, CHARGING, NONE, UNAVAILABLE
enum BatteryChargingStatus : String {
    case pluggedUSB = "PLUGGED_USB"
    case pluggedAC = "PLUGGED_AC"
    case charging = "CHARGING"
    case none = "NONE"
    case unavailable = "UNAVAILABLE"
}

class BatteryStatusInit: Codable{
    var charge: Int?
    var expectedLife: Int?
    var chargingStatus: String?
    var timestamp: Int?
    
    init(batteryObject: [String: AnyObject]?) {
        charge = batteryObject?[BatteryStatusParamKeyValues.charge.rawValue] as? Int
        expectedLife = batteryObject?[BatteryStatusParamKeyValues.expectedLife.rawValue] as? Int
        chargingStatus = batteryObject?[BatteryStatusParamKeyValues.chargingStatus.rawValue] as? String
        timestamp = batteryObject?[BatteryStatusParamKeyValues.timestamp.rawValue] as? Int
    }
}

extension BatteryStatusInit{
    var dictionary: [String: AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: AnyObject] }
    }
}

//
//  LTConstants.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 21/08/21.
//

import Foundation

//MARK:- LOCATION TRACKER CONSTANTS
struct LTConstants {
    
    //MARK:- Alert Message Constants
    struct AlertMessages {
        static let DefaultErrorTitle = ""
        static let DefaultErrorMessage =  "Sorry! something went weird on this side. Please try again. "
        static let alertOkTitle =  "OK"
        static let alertStopTitle = "Stop now"
        static let alertStartTitle = "Start now"
    }
    
    //MARK:- Token keys
    struct SecureTokenKeys {
        static let accesstoken = "com.locus.accesstoken"
    }
    
    //MARK:- user Default keys
    struct UserDefaultKeys {
        static let expiryTime = "threshold_location_tracking_expiry_time"
        static let expiryDistance = "threshold_location_tracking_expiry_distance"
    }
}

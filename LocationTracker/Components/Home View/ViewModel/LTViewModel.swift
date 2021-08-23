//
//  LTViewModel.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation
import UIKit
import CoreLocation

extension LTViewModel {
    fileprivate struct PageConstants {
        //Title
        static let title = "Location Tracker"
        //LoaderLabel
        static let loaderLabelText = "Location is being tracked"
        //Text
        static let startTrackerText = "Start Tracking"
        static let stopTrackerText = "Stop Tracking"
        //Tracking Button Colors
        static let trackerButtonEnabledColor = "#EC008C"
        static let trackerButtonDisabledColor = "#7d7979"
        //Color
        static let trackerTextColor = "#FFFFFF"
        //Font
        static let trackerButtonTextFont = UIFont.setupFont(14.0)
        static let loaderLabelTextFont = UIFont.setupFont(18.0)
        //Alignment
        static let trackerButtonTextAlignment = NSTextAlignment.center
        
        //Alert messages
        static let trackingStartedTitle = ""
        static let trackingStartedMessage = "User location tracking started."
        static let trackingAlreadyStartedTitle = ""
        static let trackingAlreadyStartedMessage = "User location tracking already in progress."
        static let trackingNotStartedTitle = ""
        static let trackingNotStartedMessage = "User location tracking isn't ON."
        static let positiveAlertTitle = "Success!"
        static let positiveAlertMessage = "User location posted successfully."
        static let negativeAlertTitle = "Failure!"
        static let negativeAlertMessage = "Something went wrong. User location data couldn't be posted."
    }
}

class LTViewModel {
    
    //MARK:- Properties
    let title: String
    let startTrackingAttributedTitle: NSAttributedString?
    let stopTrackingAttributedTitle: NSAttributedString?
    let loaderLabelAttributedText: NSAttributedString?
    
    let user = User()
    let client = Client()
    
    //For API call request body
    var locationObject: [String: AnyObject] = [:]
    var batteryStatusObject: [String: AnyObject] = [:]
    
    var dataSource: LocationPostResponse?
    var apiInterface = LTWorker()
    
    //Delegate for callback to TrackerViewController
    var delegate: ExpiryNoticeProtocol?
    
    // Properties for continuos distance calculation
    var firstLocation: CLLocation?
    var currentLocation: CLLocation? {
        didSet {
            if let firstLocation = firstLocation, let currentLocation = currentLocation, currentLocation.distance(from: firstLocation) > getLocationTrackingExpiryDistance() {
                delegate?.postResultsDueExpiry()
            }
        }
    }
    
    //Properties for continuous time calculation
    var currentTime: Date = Date()
    
    //For callback to TrackerViewController to show alert
    var isLocationPosted: Bool?
    
    //MARK:- Initialise ViewModel
    init() {
        title = PageConstants.title
        startTrackingAttributedTitle = Helper.getAttributedText(text: PageConstants.startTrackerText, color: PageConstants.trackerTextColor, alignment: PageConstants.trackerButtonTextAlignment, font: PageConstants.trackerButtonTextFont)
        stopTrackingAttributedTitle = Helper.getAttributedText(text: PageConstants.stopTrackerText, color: PageConstants.trackerTextColor, alignment: PageConstants.trackerButtonTextAlignment, font: PageConstants.trackerButtonTextFont)
        loaderLabelAttributedText = Helper.getAttributedText(text: PageConstants.loaderLabelText, color: PageConstants.trackerTextColor, alignment: PageConstants.trackerButtonTextAlignment, font: PageConstants.loaderLabelTextFont)
        
    }
    
    //MARK:- Methods to retrieve Alert messages
    func getPositiveAlertMessages() -> (String, String) {
        return (PageConstants.positiveAlertTitle, PageConstants.positiveAlertMessage)
    }
    
    func getTrackingStartedAlertMessages() -> (String, String) {
        return (PageConstants.trackingStartedTitle, PageConstants.trackingStartedMessage)
    }
    
    func getAlreadyStartedAlertMessages() -> (String, String) {
        return (PageConstants.trackingAlreadyStartedTitle, PageConstants.trackingAlreadyStartedMessage)
    }
    
    func getTrackingNotStartedAlertMessages() -> (String, String) {
        return (PageConstants.trackingNotStartedTitle, PageConstants.trackingNotStartedMessage)
    }
    
    func getNegativeAlertMessages() -> (String, String) {
        return (PageConstants.negativeAlertTitle, PageConstants.negativeAlertMessage)
    }
    
    func getTrackingButtonColor() -> (UIColor, UIColor) {
        return (UIColor(hexString: PageConstants.trackerButtonEnabledColor)!, UIColor(hexString: PageConstants.trackerButtonDisabledColor)!)
    }
    
    //MARK:- startTracking() will help in keeping track of initial time and disance
    func startTracking() {
        if (UserDefaultsManager.shareInstance.getExpiryStartTime() == nil){
            //this registers the location tracking start time, pls set the current date value to our expiry manager
            UserDefaultsManager.shareInstance.saveExpiryStartTime(object: Date())
            currentTime = Date() // For reference for Continuous time calculation for posting
            
            //To keep updating the current time object after every 60 sec(1 min)
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.currentTime = Date()
                if let expiryTime = UserDefaultsManager.shareInstance.getExpiryStartTime(){
                    let currentTime = NSDate()
                    let duration = currentTime.timeIntervalSince(expiryTime)
                    UserDefaultsManager.shareInstance.removeExpiryStartTime()
                    if duration > self.getLocationTrackingExpiryTime(){
                        //clear data
                        self.delegate?.postResultsDueExpiry()
                        UserDefaultsManager.shareInstance.removeExpiryStartTime()
                        timer.invalidate()
                    }
                }
            }
            
        }
    }
    
    //MARK:- stopTracking() will help in keeping track of initial time and disance
    func stopTracking(completion: @escaping (_ locationPosted: Bool) -> ()) {
        var locationPosted = false
        setUpBatteryStatusObject()
        postLocation()
        locationPosted = isLocationPosted ?? false
        completion(locationPosted)
    }
    
    //MARK:- API Parameter body objects setting
    func setUpBatteryStatusObject() {
        let currentBatterylevel = UIDevice.current.batteryLevel
        var chargingStatus = ""
        let batteryState = UIDevice.current.batteryState
        switch batteryState {
        case .unknown: chargingStatus = BatteryChargingStatus.unavailable.rawValue
        case .full: chargingStatus = BatteryChargingStatus.pluggedAC.rawValue // assuming plugged_ac, plugged_usb means same and full
        case .charging: chargingStatus = BatteryChargingStatus.charging.rawValue
        case .unplugged: chargingStatus = BatteryChargingStatus.none.rawValue
        @unknown default:
            print(batteryState)
        }
        batteryStatusObject[BatteryStatusParamKeyValues.charge.rawValue] = (currentBatterylevel * 100) as AnyObject
        batteryStatusObject[BatteryStatusParamKeyValues.expectedLife.rawValue] = (UIDevice.current.batteryState) as AnyObject
        batteryStatusObject[BatteryStatusParamKeyValues.chargingStatus.rawValue] = chargingStatus as AnyObject
        batteryStatusObject[BatteryStatusParamKeyValues.timestamp.rawValue] = 0 as AnyObject  //later
    }
    
    func setLocationObject(with currentLocation: CLLocation, address: String, from firstLocation: CLLocation) {
        
        self.firstLocation = firstLocation
        self.currentLocation = currentLocation
//        Allowed Values: PLACE, DROPPED_PIN
        var type = ""
        switch "PLACE" {
        case "PLACE":
            type = "PLACE"
        case "DROPPED_PIN" : type = "DROPPED_PIN"
        default:
            print(type)
        }
        locationObject[LocationStatusParamKeyValues.longitude.rawValue] = currentLocation.coordinate.longitude as AnyObject
        locationObject[LocationStatusParamKeyValues.latitude.rawValue] = currentLocation.coordinate.latitude as AnyObject
        locationObject[LocationStatusParamKeyValues.name.rawValue] = address as AnyObject // check
        locationObject[LocationStatusParamKeyValues.address.rawValue] = address as AnyObject
        locationObject[LocationStatusParamKeyValues.accuracy.rawValue] = LocationManager.sharedInstance.locationManager.desiredAccuracy.magnitude as AnyObject // check
        locationObject[LocationStatusParamKeyValues.provider.rawValue] = "GPS" as AnyObject // assume
        locationObject[LocationStatusParamKeyValues.timestamp.rawValue] = currentLocation.timestamp as AnyObject
        locationObject[LocationStatusParamKeyValues.speed.rawValue] = currentLocation.speed as AnyObject
        locationObject[LocationStatusParamKeyValues.direction.rawValue] = currentLocation.course as AnyObject
        locationObject[LocationStatusParamKeyValues.distance.rawValue] = currentLocation.distance(from: firstLocation) as AnyObject
        locationObject[LocationStatusParamKeyValues.isGPSEnabled.rawValue] = CLLocationManager.locationServicesEnabled() as AnyObject
        locationObject[LocationStatusParamKeyValues.type.rawValue] = type as AnyObject // assuming "PLACE"
        locationObject[LocationStatusParamKeyValues.isValid.rawValue] = true as AnyObject // assuming locus system has decided the validity of location
    }
    
    //MARK:- Get Default/ Threshold from Info.plist for expiry time/distance
    /// Gives Locationtracking expiry time
    func getLocationTrackingExpiryTime() -> TimeInterval{
        let defaultTimeInterval: TimeInterval = 120 //which is basically 2 mins as mentioned in the problem statement
        let thresholdExpiryValue = Bundle.main.infoDictionary?[LTConstants.UserDefaultKeys.expiryTime] as? NSNumber ?? 0
        if let timeInterval = TimeInterval(exactly: thresholdExpiryValue){
            return timeInterval
        }
        return defaultTimeInterval
    }
    
    /// Gives Locationtracking expiry distance
    func getLocationTrackingExpiryDistance() -> Double {
        let defaultTimeInterval: TimeInterval = 100 //which is basically 2 mins as mentioned in the problem statement
        if let thresholdExpiryValue = Bundle.main.infoDictionary?[LTConstants.UserDefaultKeys.expiryDistance] as? Double {
            return thresholdExpiryValue
        }
        return defaultTimeInterval
    }
    
    //MARK:- API call to post results to backend
    func postLocation() {
        guard let locationPostQueryParams = LocationPostInit(locationObject: LocationStatusInit(locationObject: locationObject), batteryStatusObject: BatteryStatusInit(batteryObject: batteryStatusObject)).dictionary else {
            return
        }
        apiInterface.postUserLocation(userId: user.name, clientId: client.clientId, params: locationPostQueryParams) { [weak self](successResponse) in
            guard let self = self else {
                return
            }
            let response = successResponse
            if let result = response.status, result == 200 {
                self.isLocationPosted = true
            } else {
                self.isLocationPosted = false
            }
        } failure: { [weak self](error) in
            guard let self = self else {
                return
            }
            self.isLocationPosted = false
        }
    }
}

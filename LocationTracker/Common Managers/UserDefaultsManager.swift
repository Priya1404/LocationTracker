//
//  UserDefaultsManager.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation

class UserDefaultsManager {
    
    // MARK: Singleton
    static let shareInstance = UserDefaultsManager()
    private init() {}
    
    enum SaveManagerKeys: String{
        case locationTrackingExpiry
    }
    
    // MARK: Manager
    func save(object: Any?, key: SaveManagerKeys) {
        guard let object = object else {return}
        standard().set(object, forKey: key.rawValue)
        sync()
    }
    
    func get(key: SaveManagerKeys) -> Any? {
        return standard().object(forKey: key.rawValue)
    }
    
    func delete(key: SaveManagerKeys) {
        standard().removeObject(forKey: key.rawValue)
        sync()
    }
    
    // MARK: Helpers
    func standard () -> UserDefaults {
        return UserDefaults.standard
    }
    
    func sync () {
        standard().synchronize()
    }
}

//Location Tracking expiry
extension UserDefaultsManager {
    func saveExpiryStartTime(object: Any?){
        save(object: object, key: .locationTrackingExpiry)
    }
    
    func getExpiryStartTime() -> Date? {
        if let test = get(key: .locationTrackingExpiry) as? Date{
            return test
        }
        return nil
    }
    
    func removeExpiryStartTime(){
        delete(key: .locationTrackingExpiry)
    }
}

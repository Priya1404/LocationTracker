//
//  KeychainManager.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 23/08/21.
//

import Foundation
import KeychainSwift

class KeychainManager {
    
    static let sharedInstance = KeychainManager()
    
    func getValueforKey(_ key: String) -> String?{
        return KeychainSwift().get(key)
    }
    
    func setValue(_ value: String,forKey: String){
        KeychainSwift().set(value, forKey: forKey)
    }
    
    func delete(_ key: String){
        KeychainSwift().delete(key)
    }
}

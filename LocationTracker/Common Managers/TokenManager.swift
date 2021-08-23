//
//  TokenManager.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 23/08/21.
//

import Foundation

class TokenManager {
    
    //MARK:- Singleton
    static let sharedInstance = TokenManager()
    private init() {}
    
    //MARK:- Access/Auth Token - get, set, delete
    func getAccessToken() -> String? {
        return KeychainManager.sharedInstance.getValueforKey(LTConstants.SecureTokenKeys.accesstoken)
    }
    
    func setAccessToken(token: String) {
        KeychainManager.sharedInstance.setValue(token, forKey: LTConstants.SecureTokenKeys.accesstoken)
    }
    
    func deleteAccessToken() {
        KeychainManager.sharedInstance.delete(LTConstants.SecureTokenKeys.accesstoken)
    }

}

//
//  LTWorker.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 22/08/21.
//

import Foundation

class LTWorker {
    
    /// post user's location  data
     func postUserLocation(userId: String, clientId: String, params: [String: AnyObject], success: @escaping (LocationPostResponse) -> Void, failure: @escaping (Error) -> Void) {
        let apiendPoint  = String(format: URLManager.sharedInstance.getApiURLForType(apiType: .locationPost), userId, clientId)
        guard let urlComponents = URLComponents(string: apiendPoint) else {
            return
        }
        guard let urlString = urlComponents.url?.absoluteString else {
            return
        }
        NetworkManager.sharedInstance.request(url: urlString, paramBody: params, requestType: "POST", success: success, failure: failure)
    }
}

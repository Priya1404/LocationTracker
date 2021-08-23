//
//  NetworkManager.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 21/08/21.
//

import Foundation

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    private let session = URLSession.shared
    
    /// Request with URl & get data
    func request<Model: Codable>(url: String, paramBody: [String: AnyObject], requestType: String?, success: @escaping (Model) -> Void, failure: @escaping (Error) -> Void) {
        // Create a URLRequest for an API endpoint
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            // Configure request authentication
            request.setValue(
                "authToken",
                forHTTPHeaderField: "Authorization"
            )
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            // Serialize HTTP Body data as JSON
            let bodyData = try? JSONSerialization.data(
                withJSONObject: paramBody,
                options: []
            )
            
            // Change the URLRequest to a POST request
            request.httpMethod = requestType
            request.httpBody = bodyData
            
            // Create the HTTP request
            let task = session.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    do {
                        if let error = error {
                            // Handle HTTP request error
                            failure(error)
                        } else if let data = data {
                            // Handle HTTP request response
                            let json1 = try JSONSerialization.jsonObject(with: data, options: [])
                            debugPrint(json1)
                            let json = try JSONDecoder().decode(Model.self, from: data)
                            success(json)
                        }
                    } catch let error {
                        failure(error)
                    }
                }
            }
            task.resume()
        }
    }
}

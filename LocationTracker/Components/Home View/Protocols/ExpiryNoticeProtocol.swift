//
//  ExpiryNoticeProtocol.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 23/08/21.
//

import Foundation

//MARK:- Protocol for triggering events from LTViewModel to TrackerViewController
protocol ExpiryNoticeProtocol {
    func postResultsDueExpiry()
}

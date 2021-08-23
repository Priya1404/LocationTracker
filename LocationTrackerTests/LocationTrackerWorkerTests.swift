//
//  LocationTrackerWorkerTests.swift
//  LocationTrackerTests
//
//  Created by Priya Srivastava on 23/08/21.
//

import XCTest
@testable import LocationTracker

class LocationTrackerWorkerTests: XCTestCase {
    
    var postResultsWorker: LTWorker!
    var expec = XCTestExpectation(description: "PostResult")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        postResultsWorker = LTWorker()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        postResultsWorker = nil
    }
    
    func testLocationPostCall() throws{
        var locationObject = [String: AnyObject]()
        locationObject[LocationStatusParamKeyValues.longitude.rawValue] = 34 as AnyObject
        locationObject[LocationStatusParamKeyValues.latitude.rawValue] = 112 as AnyObject
        let batteryStatusObject = [String: AnyObject]()
        guard let locationPostQueryParams = LocationPostInit(locationObject: LocationStatusInit(locationObject: locationObject), batteryStatusObject: BatteryStatusInit(batteryObject: batteryStatusObject)).dictionary else {
            return
        }
        postResultsWorker.postUserLocation(userId: "test", clientId: "candidate", params: locationPostQueryParams) { [weak self](result) in
            if let responseStatus = result.status, responseStatus == 200 {
                self?.expec.fulfill()
                XCTAssert(true, "Location posted to server")
            }
        } failure: { (error) in
            XCTFail(error.localizedDescription)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


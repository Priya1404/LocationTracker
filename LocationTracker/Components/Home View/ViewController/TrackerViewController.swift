//
//  TrackerViewController.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 21/08/21.
//

import UIKit
import CoreLocation

class TrackerViewController: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var startTrackingButton: UIButton!
    @IBOutlet weak var stopTrackingButton: UIButton!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderLabel: UILabel!
    @IBOutlet weak var loaderIndicator: UIActivityIndicatorView!
    
    //MARK:- Properties
    var pageViewModel = LTViewModel()
    var locationManager: CLLocationManager?
    
    //MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIDevice.current.isBatteryMonitoringEnabled = true
        pageViewModel.delegate = self
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpLocationManager()
    }
    
    //MARK:- Set up UI
    func setUpUI() {
        title = pageViewModel.title
        startTrackingButton.setAttributedTitle(pageViewModel.startTrackingAttributedTitle, for: .normal)
        stopTrackingButton.setAttributedTitle(pageViewModel.stopTrackingAttributedTitle, for: .normal)
        startTrackingButton.backgroundColor = pageViewModel.getTrackingButtonColor().0
        stopTrackingButton.backgroundColor = pageViewModel.getTrackingButtonColor().1
        loaderView.isHidden = true
        loaderLabel.attributedText = pageViewModel.loaderLabelAttributedText
    }
    
    //MARK:- Set up Location Manager
    func setUpLocationManager() {
        locationManager = LocationManager.sharedInstance.locationManager
        guard let locationManager = locationManager else {
            return
        }
        // Ask for Authorisation from the User.
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    //MARK:- IBActions
    @IBAction func startTrackingTapped(_ sender: UIButton) {
        if !loaderIndicator.isAnimating {
            self.showAlert(self, title: self.pageViewModel.getTrackingStartedAlertMessages().0, message: self.pageViewModel.getTrackingStartedAlertMessages().1)
            startTracking()
        } else {
            let okAction = UIAlertAction(title: LTConstants.AlertMessages.alertOkTitle, style: .default, handler: nil)
            let stopAction = UIAlertAction(title: LTConstants.AlertMessages.alertStopTitle, style: .default) { [weak self](_) in
                guard let self = self else {return}
                self.stopTracking()
            }
            self.showAlert(self, title: self.pageViewModel.getAlreadyStartedAlertMessages().0, message: self.pageViewModel.getAlreadyStartedAlertMessages().1, actions: [okAction, stopAction])
        }
    }
    
    @IBAction func stopTrackingTapped(_ sender: UIButton) {
        if loaderIndicator.isAnimating {
            stopTracking()
        } else  {
            let okAction = UIAlertAction(title: LTConstants.AlertMessages.alertOkTitle, style: .default, handler: nil)
            let startAction = UIAlertAction(title: LTConstants.AlertMessages.alertStartTitle, style: .default) { [weak self](_) in
                guard let self = self else {return}
                self.startTracking()
            }
            self.showAlert(self, title: self.pageViewModel.getTrackingNotStartedAlertMessages().0, message: self.pageViewModel.getTrackingNotStartedAlertMessages().1, actions: [okAction, startAction])
        }
    }
    
    //MARK:- Changes to do on clicking on Start Tracking button
    func startTracking() {
        pageViewModel.startTracking()
        loaderView.isHidden = false
        startTrackingButton.backgroundColor = pageViewModel.getTrackingButtonColor().1
        stopTrackingButton.backgroundColor = pageViewModel.getTrackingButtonColor().0
        loaderIndicator.startAnimating()
        locationManager?.startUpdatingLocation()  // start tracking location
    }
    
    //MARK:- Changes to do on clicking on Start Tracking button
    func stopTracking() {
        self.loaderIndicator.stopAnimating()
        self.loaderView.isHidden = true
        startTrackingButton.backgroundColor = pageViewModel.getTrackingButtonColor().0
        stopTrackingButton.backgroundColor = pageViewModel.getTrackingButtonColor().1
        self.locationManager?.stopUpdatingLocation() // stop tracking location
        pageViewModel.stopTracking { isLocationPosted in
            if isLocationPosted {
                self.showAlert(self, title: self.pageViewModel.getPositiveAlertMessages().0, message: self.pageViewModel.getPositiveAlertMessages().1)
            } else {
                self.showAlert(self, title: self.pageViewModel.getNegativeAlertMessages().0, message: self.pageViewModel.getNegativeAlertMessages().1)
            }
        }
    }
}

//MARK:- CLLocationManagerDelegate methods
extension TrackerViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last, let first = locations.first else { return }
        print("location:: (\(last.coordinate.longitude) | \(last.coordinate.latitude)")
        var addressOfLastLocation = ""
        lookUpCurrentLocation { (placemark) in
            if let placemark = placemark {
                addressOfLastLocation = placemark.description
            }
        }
        pageViewModel.setLocationObject(with: last, address: addressOfLastLocation, from: first)
    }
    
    // Convert between a latitude/longitude pair and a more user-friendly description of that location.
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager?.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    completionHandler(firstLocation)
                                                }
                                                else {
                                                    // An error occurred during geocoding.
                                                    completionHandler(nil)
                                                }
                                            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
}

//MARK:- ExpiryNoticeProtocol
extension TrackerViewController: ExpiryNoticeProtocol {
    
    func postResultsDueExpiry() {
        stopTracking()
    }
}

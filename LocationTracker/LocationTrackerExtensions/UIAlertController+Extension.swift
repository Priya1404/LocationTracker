//
//  UIAlertController+Extension.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 21/08/21.
//

import Foundation
import UIKit

//MARK:- Custom UIAlertController extension
class LTAlertController: UIAlertController {
    
    var isSourceViewSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSourceViewSet == false{
            fatalError("Use LTAlertController.create() to instantiate alert")
        }
    }
    
    class func create(title: String?, message: String?, preferredStyle: UIAlertController.Style,sourceView:UIView) -> LTAlertController {
        let alertController =  LTAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        alertController.popoverPresentationController?.permittedArrowDirections = [.up , .down]
        alertController.isSourceViewSet = true
        return alertController
    }
}

extension LTAlertController{
    
    /// extension to add actions to alert controller
    ///
    /// - Parameter actions: array of valid actions
    func addActions(actions : [UIAlertAction]){
        for action in actions{
            self.addAction(action)
        }
    }
}

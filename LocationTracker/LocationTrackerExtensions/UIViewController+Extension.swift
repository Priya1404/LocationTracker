//
//  UIViewController+Extension.swift
//  LocationTracker
//
//  Created by Priya Srivastava on 23/08/21.
//

import Foundation
import UIKit

//MARK:- Extension to show Alert on the specific view controller
extension UIViewController {
    
    func showAlert(_ vc : UIViewController,title : String? = nil ,message : String, actions : [UIAlertAction] = [UIAlertAction(title: "OK", style: .default, handler: nil)]){
        let alert = LTAlertController.create(title: title ?? "", message: message, preferredStyle: .alert, sourceView: vc.view)
        for action in actions{
            alert.addAction(action)
        }
        vc.present(alert, animated: true, completion: nil)
    }
}

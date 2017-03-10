//
//  AddStudentViewController.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/22/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import UIKit

class AddStudentViewController:UIViewController {
    
    
    @IBOutlet weak var enterLocation: UITextField!
    
    @IBOutlet weak var enterWebsite: UITextField!
    
    @IBAction func actionDismiss(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    
    var address: String {
        get {
            return enterLocation.text!
        }
    }
    var website: String {
        get {
            return enterWebsite.text!
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navVC = segue.destination as? UINavigationController
        
        let controller = navVC?.viewControllers.first as! AddSingleLocationController
        controller.address = enterLocation.text!
        controller.website = enterWebsite.text!
    }
}

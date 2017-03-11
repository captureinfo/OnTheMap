//
//  ViewController.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/1/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//
import UIKit
import MapKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func loginValidator(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        let alertController = UIAlertController()
        var title: String?
        if error != nil {
            title = "Network Error"
        }
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        if statusCode == nil || statusCode! < 200 || statusCode! > 299 {
            title = "Invalid Username or Password"
        }
        
        if data == nil {
            title = "No data was returned by the request"
        }
        if title != nil {
            alertController.title = title!
            let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel)
            alertController.addAction(cancelAction)
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            })
            return false
        }
        return true
    }
    
    @IBAction func loginWithUdacity(_ sender: UIButton) {
        NetworkService.sharedInstance.loginWithUdacity(usernameText: username.text!, passwordText: password.text!, validator: loginValidator) {
            let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as UIViewController
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

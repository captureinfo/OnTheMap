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
    
    @IBAction func loginWithUdacity(_ sender: UIButton) {
        let passwordText: String = password.text!
        let usernameText: String = username.text!
        let request = NSMutableURLRequest(url: URL(string:"https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = ("{\"udacity\": {\"username\":\"" + usernameText + "\", \"password\": \"" + passwordText + "\"}}").data(using: String.Encoding.utf8)
        let session = URLSession.shared
        var accountDictionary = [String:AnyObject]()
        let task = session.dataTask(with:request as URLRequest) {
            data, response, error in
            let alertController = UIAlertController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onTheMap = true
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
                return
            }
            
            
            let range = Range(uncheckedBounds: (5, (data?.count)!))
            let newData = data?.subdata(in: range)
            
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            OperationQueue.main.addOperation{
                let viewController = self.storyboard!.instantiateViewController(withIdentifier:         "TabBarViewController") as UIViewController
                self.present(viewController, animated: true, completion: nil)
                accountDictionary = try! JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String : AnyObject]
                let account = accountDictionary["account"] as! [String : AnyObject]
                self.appDelegate.accountKey = account["key"] as? String
            }
        }
        task.resume()
    }
    
}

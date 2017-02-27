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
            if error != nil {
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
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
    
    @IBAction func logoutWithUdacity(_sender: UIButton) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count - 5))
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
}

//
//  NetworkService.swift
//  OnTheMap
//
//  Created by Yang Gao on 3/7/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import MapKit

class NetworkService {
    static let sharedInstance = NetworkService()
    
    func addCredentialsToRequest(_ request: NSMutableURLRequest) -> NSMutableURLRequest {
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
    
    func logoutWithUdacity() {
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
    private init() {}
    
    
    func getStudentsLocations(renderer : @escaping () -> ()) {
        let request = NetworkService.sharedInstance.addCredentialsToRequest(NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?&order=-updatedAt&limit=100")!))
        let session = URLSession.shared
        var mapDictionary = [String:AnyObject]()
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }else {
                mapDictionary = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                let locations = mapDictionary["results"] as! [[String : AnyObject]]
                
                // The "locations" array is loaded with the sample data below. We are using the dictionaries
                // to create map annotations. This would be more stylish if the dictionaries were being
                // used to create custom structs. Perhaps StudentLocation structs.
                
                var students = [Student]()
                for dictionary in locations {
                    let filteredPairs = dictionary.filter({!($1 is NSNull)})
                    var filteredDict = [String:AnyObject]()
                    for (k, v) in filteredPairs {
                        filteredDict[k] = v
                    }
                    
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    if (Set(["latitude", "longitude", "firstName", "lastName", "mediaURL", "uniqueKey"]).isSubset(of: Set(filteredDict.keys))) {
                        students.append(Student(dictionary: filteredDict))
                    }
                }
                
                OnTheMapModel.sharedInstance.students = students
                
                
                DispatchQueue.main.async(execute: renderer)
            }
        }
        task.resume()
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func updateStudentLocation(_ coordinates: CLLocationCoordinate2D, address: String, website: String, networkErrorHandler: @escaping () -> (), renderer: @escaping () -> ()) {
        var urlString: String
        if appDelegate.onTheMap {
            urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(OnTheMapModel.sharedInstance.objectId!)"
        } else {
            urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        }
        let request = NetworkService.sharedInstance.addCredentialsToRequest(NSMutableURLRequest(url: URL(string: urlString)!))
        let accountKey = appDelegate.accountKey
        request.httpMethod = appDelegate.onTheMap ? "PUT" : "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(accountKey!)\", \"firstName\": \"\(OnTheMapModel.sharedInstance.firstName!)\", \"lastName\": \"\(OnTheMapModel.sharedInstance.lastName!)\", \"mapString\": \"\(address)\", \"mediaURL\": \"\(website)\", \"latitude\": \(coordinates.latitude), \"longitude\": \(coordinates.longitude)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                networkErrorHandler()
            } else {
                renderer()
            }
        }
        task.resume()
    }
}

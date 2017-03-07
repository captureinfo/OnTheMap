//
//  GetData.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/20/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import MapKit
class GetData {
    func getStudentsLocations(renderer : @escaping () -> ()) {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?&order=-updatedAt&limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
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
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.model.students = students
                
                
                renderer()
            }
        }
        task.resume()
    }
    
}

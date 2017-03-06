//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/20/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import MapKit


struct Student {
    var firstName : String
    var lastName : String
    var latitude : CLLocationDegrees
    var longitude : CLLocationDegrees
    var mediaURL : String
    var uniqueKey : String
    var mapString : String?
    init(dictionary: [String: AnyObject]) {
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.latitude = CLLocationDegrees(dictionary["latitude"] as! Double)
        self.longitude = CLLocationDegrees(dictionary["longitude"] as! Double)
        self.mediaURL = dictionary["mediaURL"] as! String
        self.uniqueKey = dictionary["uniqueKey"] as! String
    }
}

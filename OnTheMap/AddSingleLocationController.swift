//
//  AddSingleLocationController.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/26/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class AddSingleLocationController: UIViewController, MKMapViewDelegate {
    var firstName: String!
    var lastName: String!
    var address: String!
    var website: String!
    var coordinates: CLLocationCoordinate2D?
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func finish(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.onTheMap {
            self.putStudentLocation(self.coordinates!, sender: sender)
        }else {
            self.postAStudentLocation(self.coordinates!, sender: sender)
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func centerMapOnLocation(location: CLLocation)
    {
        let regionRadius: CLLocationDistance = 20000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    override func viewDidLoad() {
        getGeoLocation(address)
        self.mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func getGeoLocation(_ address: String) {
        let geocoder = CLGeocoder()
        
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.white
        self.view.addSubview(indicator)
        indicator.startAnimating()
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                self.showAlert(title: "Not a valid address")
            }
            if let placemark = placemarks?.first {
                self.coordinates = placemark.location!.coordinate
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = self.coordinates!
                annotation.title = "\(self.firstName) \(self.lastName)"
                annotation.subtitle = self.website
                self.mapView.addAnnotations([annotation])
                
                let homeLocation = CLLocation(latitude: (self.coordinates?.latitude)!, longitude:(self.coordinates?.longitude)!)
                self.centerMapOnLocation(location: homeLocation)
                
                //For stop:
                indicator.stopAnimating()
                indicator.hidesWhenStopped = true
            }
        })
    }
    
    
    func getPublicUserData() {
        let baseURL = "https://www.udacity.com/api/users/"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let accountKey = appDelegate.accountKey
        let newURL = baseURL + accountKey!
        let request = NSMutableURLRequest(url: URL(string: newURL)!)
        let session = URLSession.shared
        var accountDictionary = [String:AnyObject]()
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count - 5))
            let newData = data?.subdata(in: range) /* subset response data! */
            OperationQueue.main.addOperation{
                accountDictionary = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                self.firstName = accountDictionary["firstName"] as! String!
                self.lastName = accountDictionary["lastName"] as! String!
            }
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
    
    func postAStudentLocation(_ coordinates: CLLocationCoordinate2D, sender: AnyObject) {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        let accountKey = appDelegate.accountKey
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \(accountKey), \"firstName\": \(self.firstName), \"lastName\": \(self.lastName),\"mapString\": \(self.address), \"mediaURL\": \(self.website),\"latitude\": \(coordinates.latitude), \"longitude\": \(coordinates.longitude)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                self.showAlert(title:"Network not available")
            } else {
                self.performSegue(withIdentifier: "finishSegue", sender: sender)
            }
        }
        task.resume()
    }
    
    func putStudentLocation(_ coordinates: CLLocationCoordinate2D, sender: AnyObject) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/8ZExGR5uX8"
        let url = URL(string: urlString)
        let accountKey = appDelegate.accountKey
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \(accountKey), \"firstName\": \(self.firstName), \"lastName\": \(self.lastName), \"mapString\": \(self.address), \"mediaURL\": \(self.website), \"latitude\": \(coordinates.latitude), \"longitude\": \(coordinates.longitude)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                self.showAlert(title:"Network not available")
            } else {
                self.performSegue(withIdentifier: "finishSegue", sender: sender)
            }
        }
        task.resume()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    func showAlert(title:String) {
        let alertController = UIAlertController()
        alertController.title = title
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)! as URL)
            }
        }
    }


}

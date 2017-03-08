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
    var address: String!
    var website: String!
    var coordinates: CLLocationCoordinate2D?
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func finish(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var method: String
        var urlString: String
        if appDelegate.onTheMap {
            method = "PUT"
            urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(self.appDelegate.model.objectId!)"
        } else {
            method = "POST"
            urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        }
        self.updateStudentLocation(self.coordinates!, sender: sender, method: method, urlString: urlString)
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
                annotation.title = "\(self.appDelegate.model.firstName!) \(self.appDelegate.model.lastName!)"
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
    
    func updateStudentLocation(_ coordinates: CLLocationCoordinate2D, sender: AnyObject, method: String, urlString: String) {
        let request = NetworkService.addCredentialsToRequest(NSMutableURLRequest(url: URL(string: urlString)!))
        let accountKey = appDelegate.accountKey
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(accountKey!)\", \"firstName\": \"\(self.appDelegate.model.firstName!)\", \"lastName\": \"\(self.appDelegate.model.lastName!)\", \"mapString\": \"\(self.address!)\", \"mediaURL\": \"\(self.website!)\", \"latitude\": \(coordinates.latitude), \"longitude\": \(coordinates.longitude)}".data(using: String.Encoding.utf8)
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

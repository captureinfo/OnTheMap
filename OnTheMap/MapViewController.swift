
import UIKit
//
//  mapViewController.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/19/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//
import UIKit
import MapKit

/**
 * This view controller demonstrates the objects involved in displaying pins on a map.
 *
 * The map is a MKMapView.
 * The pins are represented by MKPointAnnotation instances.
 *
 * The view controller conforms to the MKMapViewDelegate so that it can receive a method
 * invocation when a pin annotation is tapped. It accomplishes this using two delegate
 * methods: one to put a small "info" button on the right side of each pin, and one to
 * respond when the "info" button is tapped.
 */

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func decideToAdd(_ sender: AnyObject) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(appDelegate.accountKey!)%22%7D&order=-updatedAt&limit=100"
        
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            self.getStudentLocationHandler(data!)
        }
        task.resume()
        
    }
    
    func getStudentLocationHandler(_ data: Data) {
        let pinData = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
        if (pinData["results"] == nil || pinData["results"]?.count == 0) {
            let controller = storyboard?.instantiateViewController(withIdentifier: "AddLocationNavigationController")
            self.present(controller!, animated: true, completion:nil)
        } else {
            let alertController = UIAlertController()
            alertController.title = "You has already posted a Student Location. Would you like to overwrite the location?"
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.onTheMap = true
            let okAction = UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default) { (_) -> Void in
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddLocationNavigationController")
                self.present(controller!, animated: true, completion:nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        GetData().getStudentsLocations(renderer: {
            var annotations = [MKPointAnnotation]()
            for student in (UIApplication.shared.delegate as! AppDelegate).model.students {
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(student.firstName) \(student.lastName)"
                annotation.subtitle = student.mediaURL
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
        })
        
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                let userURL = NSURL(string: toOpen) as URL?
                if userURL == nil || !UIApplication.shared.canOpenURL(userURL!) {
                    let alertController = UIAlertController()
                    alertController.title = "Invalid Link"
                    let okAction = UIAlertAction(title:"Dismiss", style:UIAlertActionStyle.default) //{
                    //  action in self.dismiss(animated: true, completion: nil)
                    // }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    UIApplication.shared.openURL(userURL! as URL)
                }
            }
        }
    }
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
    
    @IBAction func connectParse(_sender: UIButton) {
        let urlString = "http://quotes.rest/qod.json?category=inspire"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
}

//
//  mapViewController.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/19/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func Logout(_ sender: UIBarButtonItem) {
        NetworkService.sharedInstance.logoutWithUdacity()
        self.dismiss(animated:true, completion:nil)
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func reloadData(_ sender: UIBarButtonItem) {
        self.loadData()
    }
    
    @IBAction func decideToAdd(_ sender: AnyObject) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(appDelegate.accountKey!)%22%7D"
        
        let url = URL(string: urlString)
        let request = NetworkService.sharedInstance.addCredentialsToRequest(NSMutableURLRequest(url: url!))
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
        let results = pinData["results"] as! [[String:AnyObject]]?
        if (results == nil || results?.count == 0) {
            let controller = storyboard?.instantiateViewController(withIdentifier: "AddLocationNavigationController")
            self.present(controller!, animated: true, completion:nil)
        } else {
            let studentInfo = (results?[0])!
            OnTheMapModel.sharedInstance.objectId = studentInfo["objectId"] as! String?
            OnTheMapModel.sharedInstance.firstName = studentInfo["firstName"] as! String?
            OnTheMapModel.sharedInstance.lastName = studentInfo["lastName"] as! String?
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
        self.loadData()
    }
    
    func loadData() {
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        NetworkService.sharedInstance.getStudentsLocations(renderer: {
            var annotations = [MKPointAnnotation]()
            for student in OnTheMapModel.sharedInstance.students {
                
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
            self.mapView.removeAnnotations(self.mapView.annotations)
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
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                let userURL = NSURL(string: toOpen) as URL?
                if userURL == nil || !UIApplication.shared.canOpenURL(userURL!) {
                    let alertController = UIAlertController()
                    alertController.title = "Invalid Link"
                    let okAction = UIAlertAction(title:"Dismiss", style:UIAlertActionStyle.default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    UIApplication.shared.openURL(userURL! as URL)
                }
            }
        }
    }
}

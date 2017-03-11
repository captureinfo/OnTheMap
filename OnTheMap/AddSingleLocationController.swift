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
    
    
    @IBAction func actionDismiss(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finish(_ sender: AnyObject) {
        NetworkService.sharedInstance.updateStudentLocation(self.coordinates!,
                                                            address: self.address!,
                                                            website: self.website!,
                                                            networkErrorHandler: {self.showAlert(title:"Network not available")}) {
            DispatchQueue.main.async{
                self.presentingViewController?.dismiss(animated: false, completion: nil)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
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
                annotation.title = "\(OnTheMapModel.sharedInstance.firstName!) \(OnTheMapModel.sharedInstance.lastName!)"
                annotation.subtitle = self.website
                self.mapView.addAnnotations([annotation])
                
                let homeLocation = CLLocation(latitude: (self.coordinates?.latitude)!, longitude:(self.coordinates?.longitude)!)
                self.centerMapOnLocation(location: homeLocation)
            }
            
            //For stop:
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
        })
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
        self.present(alertController, animated: true, completion: nil)
    }
    
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

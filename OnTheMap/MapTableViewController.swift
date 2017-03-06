//
//  MapTableViewController.swift
//  OnTheMap
//
//  Created by Yang Gao on 2/20/17.
//  Copyright © 2017 Yang Gao. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapTableViewController: UITableViewController {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func decideToAdd(_ sender: AnyObject) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(appDelegate.accountKey!)%22%7D"
        
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
    
    var students: [Student]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //And where you want to start animating
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        students = appDelegate.model.students
        GetData().getStudentsLocations(renderer: { self.tableView.reloadData() })
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnotationTableViewCell", for: indexPath as IndexPath) as! AnnotationTableViewCell
        let student = students[indexPath.item]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.item]
        let userURL = NSURL(string: student.mediaURL) as URL?
        
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


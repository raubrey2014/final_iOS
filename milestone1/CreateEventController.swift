//
//  CreateEventController.swift
//  milestone2
//
//  Created by Ryan Aubrey on 4/14/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit


class CreateEventController: UIViewController {
    
    //MARK: UI ELEMENTS
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var createButton: UIButton!
    
    
    //MARK: GLOBALS
    var mLongitude = 0.0
    var mLatitude = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: ACTIONS
    @IBAction func createEvent(sender: AnyObject) {
        // Create new post
        var googleGet = "https://maps.googleapis.com/maps/api/geocode/json?address="
        googleGet += (addressField.text!).stringByReplacingOccurrencesOfString(" ", withString: "+") + ","
        googleGet += (cityField.text!).stringByReplacingOccurrencesOfString(" ", withString: "+") + ","
        googleGet += (stateField.text!).stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        googleGet += "&key=AIzaSyAUl2orBA0TOyKQ9g2e5DyeTQQ54Oxnnmc"
        print(googleGet)
        
        
        //TRYING GET
        let postsUrlRequest = NSMutableURLRequest(URL: NSURL(string: googleGet)!)
        postsUrlRequest.HTTPMethod = "GET"
        
        guard let url = NSURL(string: googleGet) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard error == nil else {
                print("error using POST for our web service!!!\n")
                print(error)
                return
            }
            // parse the result as JSON, since that's what the API provides
            let post: NSDictionary
            do {
                post = try NSJSONSerialization.JSONObjectWithData(responseData,
                    options: []) as! NSDictionary
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
            
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if let geometry = result[0]["geometry"] as? NSDictionary {
                    //let number = address[0]["short_name"] as! String
                    let latitude = geometry["location"]!["lat"] as! Double
                    let longitude = geometry["location"]!["lng"] as! Double
                    
                    self.mLatitude = geometry["location"]!["lat"] as! Double
                    self.mLongitude = geometry["location"]!["lng"] as! Double
                    
                    print("\n latitude: \(latitude)")
                    print("longitude: \(longitude)")
                    
                    //**********************************************************************************************
                    //CREATE EVENT ENTRY WITH GPS INFORMATION
                    //Send Event name, longitude, latitude, date time
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd-MM-YYYY:hh:mm"
                    let dateValue = self.dateField.date
                    let dateString = dateFormatter.stringFromDate(dateValue)
                    var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/gps/"
                    databaseGet += "\(self.nameField.text!)/"
                    databaseGet += "\(dateString)/"
                    databaseGet += "\(self.mLatitude)/"
                    databaseGet += "\(self.mLongitude)"
                    print(databaseGet)
                    //TRYING GET
                    let postsUrlRequest2 = NSMutableURLRequest(URL: NSURL(string: databaseGet)!)
                    postsUrlRequest2.HTTPMethod = "GET"
                    
                    guard let url2 = NSURL(string: databaseGet) else {
                        print("Error: cannot create URL")
                        return
                    }
                    let urlRequest2 = NSURLRequest(URL: url2)
                    let config2 = NSURLSessionConfiguration.defaultSessionConfiguration()
                    let session2 = NSURLSession(configuration: config2)
                    
                    let task2 = session2.dataTaskWithRequest(urlRequest2, completionHandler: { (data, response, error) in
                        // do stuff with response, data & error here
                        guard let responseData = data else {
                            print("Error: did not receive data")
                            return
                        }
                        guard error == nil else {
                            print("error using POST for our web service!!!\n")
                            print(error)
                            return
                        }
                        
                    })
                    task2.resume()
                    //##############################################################################################
                }
            }
            
        })
        task.resume()
    }
}
//
//  CreateEventController.swift
//  milestone2
//
//  Created by Ryan Aubrey on 4/14/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreData

class CreateEventController: UIViewController, UITextFieldDelegate {
    
    //MARK: UI ELEMENTS
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var createButton: UIButton!
    
    
    
    
    //MARK: GLOBALS
    var mLongitude: Double = 0.0
    var mLatitude: Double = 0.0
    var events = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChanged:", name: UITextFieldTextDidChangeNotification, object: nil)
        createButton.enabled = false
        dateField.minimumDate = NSDate()
    }
    
    //Disable create button
    func textChanged(sender: NSNotification) {
        if nameField.hasText() && cityField.hasText() && stateField.hasText(){
            createButton.enabled = true
        }
        else {
            createButton.enabled = false
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
//        let postsUrlRequest = NSMutableURLRequest(URL: NSURL(string: googleGet)!)
//        postsUrlRequest.HTTPMethod = "GET"
        
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
                    
                    //Replaces spaces and unacceptable characters for web request
                    let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    print(databaseGet2)

                    //TRYING GET
                    guard let url2 = NSURL(string: databaseGet2) else {
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
                        let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print(dataString)
                        let attempt = Int(dataString! as String)
                        print("Event_id: ", attempt)
                        print("Event_name: ", self.nameField.text!)
                        print("Lat: ", self.mLatitude)
                        print("Long: ", self.mLongitude)
                        self.saveEvent(self.events.count, event_id: attempt!, event_name: self.nameField.text!, event_date: self.dateField.date, event_lat: self.mLatitude, event_long: self.mLongitude)
                        dispatch_async(dispatch_get_main_queue()) {
                            // update some UI
                            self.navigationController?.popViewControllerAnimated(true)
                        }

                    })
                    task2.resume()
                    //##############################################################################################
                }
            }
            
        })

        task.resume()
        

    }
    
    func saveEvent(local_id:Int, event_id: Int, event_name: String, event_date: NSDate, event_lat: Double, event_long: Double) {
        //1 get AppDelegate and ManagedObjectContext
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2 Find the relevant entity
        let entity =  NSEntityDescription.entityForName("Your_events",
            inManagedObjectContext:managedContext)
        
        let your_event = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3 Set attribute
        your_event.setValue(local_id, forKey:"local_id")
        your_event.setValue(event_id, forKey: "event_id")
        your_event.setValue(event_name, forKey: "event_name")
        your_event.setValue(event_date, forKey: "date_time")
        your_event.setValue(event_lat, forKey: "lat")
        your_event.setValue(event_long, forKey: "long")
        your_event.setValue(false, forKey: "attended")
        
        //4 Save query
        do {
            try managedContext.save()
            //5
            events.append(your_event)

        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
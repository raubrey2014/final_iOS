//
//  SpecialDetailController.swift
//  milestone1
//
//  Created by Ryan Aubrey on 4/17/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreData

class SpecialDetailController: UIViewController {
    
    var index:Int = 0
    var cityField: String = ""
    var stateField: String = ""
    var events = [NSManagedObject]()
    
    @IBOutlet weak var eventNameField: UILabel!
    
    @IBOutlet weak var eventDateTimeField: UILabel!
    
    @IBOutlet weak var eventAddress1: UILabel!
    
    @IBOutlet weak var eventAddress2: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue"{
            print("preparing for edit segue")
            if let destinationVC = segue.destinationViewController as? EditViewController{
                destinationVC.eventName = eventNameField.text!
                destinationVC.address = eventAddress1.text!
                destinationVC.city = self.cityField
                destinationVC.state = self.stateField
            }
            
            
            
        }
    }
    
    
    //MARK: FETCH
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Your_events")
        
        var tempLat:Double = 0.0
        var tempLong:Double = 0.0
        
        //3
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            events = results as! [NSManagedObject]
            print(events[index])
            let currentEvent = events[index]
            print(currentEvent.valueForKey("event_id")!)
            eventNameField.text = currentEvent.valueForKey("event_name") as! String
            let dateTime = currentEvent.valueForKey("date_time") as! NSDate
            
            tempLat = currentEvent.valueForKey("lat") as! Double
            tempLong = currentEvent.valueForKey("long") as! Double

            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, YYYY hh:mm a"
            let dateString = dateFormatter.stringFromDate(dateTime)
            eventDateTimeField.text = dateString
            
            
//            eventDateTimeField.text = currentEvent.valueForKey("date_time") as! NSTaggedDate
        
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        //#####################################################################################
        var googleGet = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
        googleGet += String(tempLat) + ","
        googleGet += String(tempLong)
        googleGet += "&key=AIzaSyAUl2orBA0TOyKQ9g2e5DyeTQQ54Oxnnmc"
        print(googleGet)
        
        guard let url = NSURL(string: googleGet) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        var tempAddress = "test1"
        var tempAddress2 = "test2"
        
        //################################## MAKE REQUEST ##########################################
        let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data, response, error) in
            //                // do stuff with response, data & error here
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard error == nil else {
                print("error using POST for our web service!!!\n")
                print(error)
                return
            }
            //                // parse the result as JSON, since that's what the API provides
            let post: NSDictionary
            do {
                post = try NSJSONSerialization.JSONObjectWithData(responseData,
                    options: []) as! NSDictionary
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            //                // now we have the post, let's just print it to prove we can access it
            //                //             print("The post is: " + post.description)
            //
            //                // the post object is a dictionary
            //                // so we just access the title using the "title" key
            //                // so check for a title and print it if we have one
            //                //            print(post.description)
            //                print(post.allKeys)
            //                //            print(post["results"])
            //                print((post["results"]).dynamicType)
            //                print((post["status"]).dynamicType)
            //
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            if let result = json["results"] as? NSArray {
                if let address = result[0]["address_components"] as? NSArray {
                    let number = address[0]["short_name"] as! String
                    let street = address[1]["short_name"] as! String
                    let city = address[2]["short_name"] as! String
                    let state = address[4]["short_name"] as! String
                    let zip = address[6]["short_name"] as! String
                    print("\n\(number) \(street), \(city), \(state) \(zip)")
                    //                    self.addressLabel.text = "\(number) \(street), \(city), \(state) \(zip)"
                    self.cityField = "\(city)"
                    self.stateField = "\(state)"
                    tempAddress = "\(number) \(street)"
                    tempAddress2 = "\(city), \(state) \(zip)"
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.eventAddress1.text = tempAddress
                        self.eventAddress2.text = tempAddress2
                        
                    })
                    
                }
            }
            
        })
        task.resume()
    }
    
}

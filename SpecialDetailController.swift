//
//  SpecialDetailController.swift
//  milestone1
//
//  Created by Ryan Aubrey on 4/17/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SpecialDetailController: UIViewController, CLLocationManagerDelegate {
    //These are set in viewWillAppear, because that is wwhere we read CoreData
    var event_id:Int = 0
    var user_id:Int = 0
    var index:Int = 0
    var foreignIndex:Int = 0
    var cityField: String = ""
    var stateField: String = ""
    var tempDate = NSDate()

    var events = [NSManagedObject]()
    @IBOutlet weak var eventNameField: UILabel!
    
    @IBOutlet weak var eventDateTimeField: UILabel!
    
    @IBOutlet weak var eventAddress1: UILabel!
    
    @IBOutlet weak var eventAddress2: UILabel!
    
    @IBOutlet weak var attendButtonField: UIButton!
    
    @IBOutlet weak var successLabel: UILabel!
    
    @IBOutlet weak var attendanceLabel: UILabel!
    
    
    //MARK: FIELDS FOR GPS
    var mLatitude: CLLocationDegrees = CLLocationDegrees()
    var mLongitude: CLLocationDegrees = CLLocationDegrees()
    
    var locationManager: CLLocationManager?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.successLabel.text = ""
        self.attendanceLabel.text = ""
        print("Here in Special!: user_id = \(self.user_id)")
        print("Here in Special!: index = \(self.index)")
        //SUCCESSFULLY ATTENDED
        //################################ ADD TO EVENT_MEMBER #############################
        var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/getNumbersForEvent/"
        databaseGet += "\(self.event_id)/"
        
        //Replaces spaces and unacceptable characters for web request
        let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        //        print(databaseGet2)
        
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
            let attempt = Int(dataString! as String)
            
            
            dispatch_async(dispatch_get_main_queue()) {
                self.attendanceLabel.text = "Currently " + (dataString! as String) + " attending!"
                
            }
        })
        
        task2.resume()
        //################################ ADD TO EVENT_MEMBER #############################
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSegue"{
            print("preparing for edit segue")
            if let destinationVC = segue.destinationViewController as? EditViewController{
                destinationVC.user_id = self.user_id
                destinationVC.index = self.index
                destinationVC.foreignIndex = self.foreignIndex
                destinationVC.eventName = eventNameField.text!
                destinationVC.address = eventAddress1.text!
                destinationVC.city = self.cityField
                destinationVC.state = self.stateField
                destinationVC.dateTime = self.tempDate
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
            //GET RESULT
            let results = try managedContext.executeFetchRequest(fetchRequest)
            events = results as! [NSManagedObject]
            let currentEvent = events[index]
            
            print(currentEvent.valueForKey("event_id")!)
            event_id = currentEvent.valueForKey("event_id") as! Int
            
            print("THIS IS THE CURRENT CREATOR: \(currentEvent.valueForKey("creator")!)")
            
            if (currentEvent.valueForKey("creator") as! Int) != user_id {
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                print(currentEvent.valueForKey("creator")!)
                print(user_id)
                
                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil), animated: true)
            }
            //CHECK IF ATTENDED
            if (currentEvent.valueForKey("attended")) != nil{
                print("value for key is not nil")
                if let b = currentEvent.valueForKey("attended") as? Bool {
                    print("b as? Bool is valid")
                    if b == true {
                        successLabel.text = "You have attended!"
                        successLabel.textColor = UIColor.greenColor()
                        attendButtonField.enabled = false
                        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil), animated: true)
                    }
                    
                    else{
                        print(b)
                    }
                }
                
            }
            //ELSE
            print("PLACEHOLDER")
            eventNameField.text = currentEvent.valueForKey("event_name") as! String
            let dateTime = currentEvent.valueForKey("date_time") as! NSDate
            
            tempLat = currentEvent.valueForKey("lat") as! Double
            tempLong = currentEvent.valueForKey("long") as! Double
            
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, YYYY hh:mm a"
            let dateString = dateFormatter.stringFromDate(dateTime)
            eventDateTimeField.text = dateString
            self.tempDate = dateTime
            
            //Setting the local var foreignIndex to the event_id so it can be passed through segue
            self.foreignIndex = currentEvent.valueForKey("event_id") as! Int
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        //#####################################################################################
        var googleGet = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
        googleGet += String(tempLat) + ","
        googleGet += String(tempLong)
        googleGet += "&key=AIzaSyAUl2orBA0TOyKQ9g2e5DyeTQQ54Oxnnmc"
        
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
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            guard error == nil else {
                print("error using POST for our web service!!!\n")
                print(error)
                return
            }
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
                if let address = result[0]["address_components"] as? NSArray {
                    let number = address[0]["short_name"] as! String
                    let street = address[1]["short_name"] as! String
                    let city = address[2]["short_name"] as! String
                    let state = address[4]["short_name"] as! String
                    let zip = address[6]["short_name"] as! String
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
    
    
    
    
    
    //### LOCATION MANAGER###
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0{
            //handle error here
            return
        }
        let newLocation = locations[0]
        mLongitude = newLocation.coordinate.longitude
        mLatitude = newLocation.coordinate.latitude
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didFailWithError error: NSError){
        print("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        print("The authorization status of location services is changed to: ", terminator: "")
        
        switch CLLocationManager.authorizationStatus(){
        case .AuthorizedAlways:
            print("Authorized")
        case .AuthorizedWhenInUse:
            print("Authorized when in use")
        case .Denied:
            print("Denied")
        case .NotDetermined:
            print("Not determined")
        case .Restricted:
            print("Restricted")
        }
        
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func createLocationManager(startImmediately startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            print("Successfully created the location manager")
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
                
                
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                /* Yes, only when our app is in use */
                createLocationManager(startImmediately: true)
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Determined",
                                      message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
                displayAlertWithTitle("Not determined", message: "Location services are undetermined for this app")
            case .Restricted:
                /* Restrictions have been applied, we have no access
                 to location services */
                displayAlertWithTitle("Restricted",
                                      message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
             Take appropriate action: for instance, prompt the
             user to enable the location services */
            print("Location services are not enabled")
        }
    }
    
    @IBAction func checkRadius(sender: AnyObject) {
        self.attendButtonField.enabled = false
        self.eventNameField.tintColor = UIColor.greenColor()
        
        var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/checkRadius/"
        databaseGet += "\(self.foreignIndex)/"
        databaseGet += "\(self.mLatitude)/"
        databaseGet += "\(self.mLongitude)"
        
        //Replaces spaces and unacceptable characters for web request
        let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

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
            //SUCCESFULLY in range
            if dataString! == "success" {
                dispatch_async(dispatch_get_main_queue()) {
                    self.successLabel.text = "You have attended!"
                    self.successLabel.textColor = UIColor.greenColor()
                    
                    //SUCCESSFULLY ATTENDED
                    //################################ ADD TO EVENT_MEMBER #############################
                    var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/attend/"
                    databaseGet += "\(self.user_id)/"
                    databaseGet += "\(self.event_id)"
                    
                    //Replaces spaces and unacceptable characters for web request
                    let databaseGet2:String = databaseGet.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                    //        print(databaseGet2)
                    
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
                        let attempt = Int(dataString! as String)
                        

                        dispatch_async(dispatch_get_main_queue()) {
                            self.attendanceLabel.text = "You have now joined " + (dataString! as String) + " other(s)!"
                            
                        }
                    })
                    
                    task2.resume()
                    //################################ ADD TO EVENT_MEMBER #############################
                    
                    //SAVES TO LOCAL DATA
                    self.updateEvent()
                }
            }
                
            //NOT in range
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.successLabel.text = "You are not in range!"
                    self.successLabel.textColor = UIColor.redColor()
                    self.attendButtonField.enabled = true
                    
                }
            }
            
        })
        task2.resume()
    }
    
    func updateEvent() {
        //Edit values in Core Data
        print("in updateEvent")
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Your_events")
        
        //3
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            events = results as! [NSManagedObject]
            let eventUpdate = events[self.index]
            
            eventUpdate.setValue(true, forKey:"attended")
            
            do {
                try eventUpdate.managedObjectContext?.save()
                //5
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
            
        }
    }
    
}

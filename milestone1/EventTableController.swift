//
//  EventTableController.swift
//  milestone1
//
//  Created by Ryan Aubrey on 4/17/16.
//  Copyright © 2016 Ryan Aubrey. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class EventTableController: UITableViewController, CLLocationManagerDelegate {

    
    @IBOutlet var eventTableView: UITableView!
    
    @IBAction func LogOutButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    var user_id = 0
    
    //FIELDS FOR GPS
    //MARK: FIELDS FOR GPS
    var mLatitude: CLLocationDegrees = CLLocationDegrees()
    var mLongitude: CLLocationDegrees = CLLocationDegrees()
    
    var locationManager: CLLocationManager?
    //###############################################
    
    var events = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HERE IN EVENT_TABLE_CONTROLLER: \(self.user_id)")
        // Do any additional setup after loading the view.
        //######################### DELETE OLD CORE DATA ################################
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        let coord = appDel.persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Your_events")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coord.executeRequest(deleteRequest, withContext: context)
        } catch let error as NSError {
            print("DELETING CORE DATA FAILED")
            debugPrint(error)
        }
        
        //######################### DELETE OLD CORE DATA ################################

        queryForCurrentEvents()
        eventTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        eventTableView.reloadData()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        queryForCurrentEvents()
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Your_events")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            events = results as! [NSManagedObject]
            eventTableView.reloadData()
            

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    //MARK: OUR PULL FROM DB FOR INTIALIAL DATA
    func queryForCurrentEvents(){
        //Take the passed in proposed new username and password
        //Check is user exists on server and return id of user if valid new user
        var databaseGet = "http://plato.cs.virginia.edu/~rma7qb/flightservice/events/"
        databaseGet += "\(user_id)"
        
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
        
        let task = session2.dataTaskWithRequest(urlRequest2, completionHandler: { (data, response, error) in
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
            
            do {
                let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSArray
                
                
                //1 get AppDelegate and ManagedObjectContext
                let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                //2 Find the relevant entity
                let entity =  NSEntityDescription.entityForName("Your_events",
                    inManagedObjectContext:managedContext)
                
                var count:Int = 0
                
                
                let listOfEvents:NSArray
                listOfEvents = json[0] as! NSArray
                
                
                for dataObject: AnyObject in listOfEvents{
                    if let jsonData = dataObject as? NSDictionary{
                        let currentEventId = Int((jsonData["event_id"] as? String)!)!
                        //Do stuff
                        print((jsonData["event_name"] as? String)!)
                        
                        //ALL IN LOOP ######################################################################
                        let your_event = NSManagedObject(entity: entity!,
                            insertIntoManagedObjectContext: managedContext)
                        
                        //3 Set attribute
                        print("RIGHT BEFORE SETTING IT: \(self.user_id)")
                        
                        print("HERE IS THE CREATOR: \( Int((jsonData["creator_id"] as? String)!)! )")
                        your_event.setValue(Int((jsonData["creator_id"] as? String)!)!, forKey: "creator")
                        your_event.setValue(count, forKey:"local_id")
                        your_event.setValue(Int((jsonData["event_id"] as? String)!)!, forKey: "event_id")
                        your_event.setValue(jsonData["event_name"], forKey: "event_name")
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd-MM-YYYY:hh:mm"
                        let dateString = (jsonData["event_date"] as? String)!
                        let dateValue = dateFormatter.dateFromString((dateString as? String)!)
                        your_event.setValue(dateValue, forKey: "date_time")
                        
                        your_event.setValue(Double((jsonData["event_lat"] as? String)!)!, forKey: "lat")
                        your_event.setValue(Double((jsonData["event_long"] as? String)!)!, forKey: "long")
                        
                        
                        //TRYING TO GET ATTEND VALUES
                        let listOfAttended:NSArray
                        //THE VALUE TO BE ASSIGNED TO ATTENDED
                        var attendedOrNot:Bool = false
                        do {
                            listOfAttended = (json[1] as? NSArray)!
                            for dataObject: AnyObject in listOfAttended{
                                if let jsonData = dataObject as? NSDictionary{
                                    if (Int((jsonData["member_id"] as? String)!)) != nil {
                                        let receivedId = (Int((jsonData["member_id"] as? String)!))
                                        if receivedId != self.user_id {
                                            print("Got something that was not of this USER")
                                        }
                                        else{
                                            if let receivedEventId = Int((jsonData["event_id"] as? String)!) {
                                                if receivedEventId == currentEventId {
                                                    attendedOrNot = true
                                                }
                                            }
                                        }
                                    }
                                    print("This is the member_id: " + (jsonData["member_id"] as? String)!)
                                    
                                }
                            }
                            your_event.setValue(attendedOrNot, forKey: "attended")

                        } catch {
                            print("No second element in json object, error parsing listOfAttending!")
                            your_event.setValue(false, forKey: "attended")

                        }
                        
                        //4 Save query
                        do {
                            try managedContext.save()
                            //5
                            self.events.append(your_event)
                            print("COUNT \(count)")
                            count += 1
                            
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                        //######################################################################################
                    }
                }
                
                
                
                
            } catch {
                print("error converting JSON")
            }
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
                self.eventTableView.reloadData()
            }
            
        })
        task.resume()
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            print("Events count: ", events.count)
            return events.count
            
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
//            let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")

            //Still stored NSManagedObject in local var
            let event = events[indexPath.row]
            
            //Accessing name field via valueForKey
            cell.textLabel!.text = event.valueForKey("event_name") as? String
        
            let attended = event.valueForKey("attended") as? Bool
        if attended == true {
            cell.detailTextLabel!.text = "Attended!"
            cell.detailTextLabel!.textColor = UIColor.greenColor()
        }
        else {
            cell.detailTextLabel!.text = "Not Attended."
            cell.detailTextLabel!.textColor = UIColor.redColor()
        }
        

//            cell!.textLabel!.text = "Example"
            return cell
    }
    
    //Events
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
//        print("Here is didselectrowatindexpath..\(indexPath.row)")
        
        performSegueWithIdentifier("SecondDetailViewController", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SecondDetailViewController"{
            print("preparing for detail segue")
            if let destinationVC = segue.destinationViewController as? SpecialDetailController{
                if let senderInt = sender as? Int{
                    destinationVC.index = senderInt
                    destinationVC.user_id = self.user_id
                    let tmpEvent = events[senderInt]
                    let tmpBool = tmpEvent.valueForKey("attended") as? Bool
                    destinationVC.attended = tmpBool!
                    
                    
                    print("TableViewController Prepare for Segue: user_id = \(self.user_id)")
                }
                
            }
        }
        else if segue.identifier == "CreateEventSegue"{
            print("preparing for CreateEventSegue segue")
            if let destinationVC = segue.destinationViewController as? CreateEventController{
                destinationVC.user_id = self.user_id
                print("CreateEventSegue Prepare for Segue: user_id = \(self.user_id)")
            }
        }
        
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
//            print("Successfully created the location manager")
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
//                displayAlertWithTitle("Not determined", message: "Location services are undetermined for this app")
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
    

}

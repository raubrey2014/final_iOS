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
    
    
    //FIELDS FOR GPS
    //MARK: FIELDS FOR GPS
    var mLatitude: CLLocationDegrees = CLLocationDegrees()
    var mLongitude: CLLocationDegrees = CLLocationDegrees()
    
    var locationManager: CLLocationManager?
    //###############################################
    
    var events = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
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
    
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            print("Events count: ", events.count)
            return events.count
            
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
            
            //Still stored NSManagedObject in local var
            let event = events[indexPath.row]
            
            //Accessing name field via valueForKey
            cell!.textLabel!.text = event.valueForKey("event_name") as? String
//            cell!.textLabel!.text = "Example"
            return cell!
    }
    
    //Events
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        print("Here is didselectrowatindexpath..\(indexPath.row)")
        
        performSegueWithIdentifier("SecondDetailViewController", sender: indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SecondDetailViewController"{
            print("preparing for detail segue")
            if let destinationVC = segue.destinationViewController as? SpecialDetailController{
                if let senderInt = sender as? Int{
                    destinationVC.index = senderInt
//                    reminderManager.currentlyEditing = senderInt
                    print("sender Int = \(senderInt)")
                }
                
            }
            
            
            
        }
    }
    
    @IBAction func reload(sender: AnyObject) {
        
        print("Attempting reload on eventTableView..")
        eventTableView.reloadData()
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
